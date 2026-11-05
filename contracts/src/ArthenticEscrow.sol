// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Mengimpor library konstanta peran (Roles.sol)
import {Roles} from "./Roles.sol";
// Mengimpor kontrak induk AttestationVerifier untuk validasi tanda tangan EIP-712
import {AttestationVerifier} from "./AttestationVerifier.sol";
// Mengimpor kontrak ArthenticNFT untuk interaksi transfer token dan query royalti
import {ArthenticNFT} from "./ArthenticNFT.sol";

/// @dev Antarmuka standar token ERC-20 untuk mendukung penyelesaian pembayaran menggunakan stablecoin (USDC)
interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

/// @title ArthenticEscrow
/// @notice Mesin penitipan dana dan penyelesaian transaksi fisik (Custodial Escrow & Settlement Engine) di Base L2 (UC-C).
/// Menerapkan aturan protokol:
/// - ADR-04: Penyelesaian Aset Ganda (Native Base ETH atau Stablecoin ERC-20 USDC).
/// - ADR-05: Pembagian Pembayaran Otomatis 3-Arah (93.5% Penjual, 5.0% Royalti Seniman ERC-2981, 1.5% Treasury Platform).
/// - C-06: Gerbang Konfirmasi Fisik via EIP-712 Attestation (dana hanya cair saat pembeli tap NFC & scan fisik).
/// - C-12: Pengembalian Otomatis 100% jika batas waktu (expiry) terlampaui tanpa konfirmasi pengiriman fisik.
contract ArthenticEscrow is AttestationVerifier {
    // Status siklus hidup transaksi escrow
    enum Status { 
        None,       // 0: Belum ada listing
        Listed,     // 1: NFT telah dititipkan oleh penjual ke escrow
        Funded,     // 2: Pembeli telah menyetor dan mengunci dana di escrow
        Completed,  // 3: Pembeli telah memindai fisik karya seni dan dana berhasil diselesaikan
        Refunded,   // 4: Batas waktu terlampaui, dana dikembalikan ke pembeli dan NFT ke penjual
        Disputed,   // 5: Terjadi sengketa kerusakan dalam transit atau ketidaksesuaian fisik
        Cancelled   // 6: Penjual membatalkan listing sebelum ada pembeli yang menyetor dana
    }

    // Struktur data listing transaksi escrow
    struct Listing {
        uint256 tokenId;        // ID unik token NFT karya seni yang dijual
        address seller;         // Alamat dompet penjual (pemilik asal)
        address buyer;          // Alamat dompet pembeli yang mengunci dana
        address currency;       // Mata uang pembayaran: address(0) untuk Base ETH, alamat kontrak untuk ERC-20 USDC
        uint256 price;          // Harga total karya seni (dalam satuan wei atau partikel USDC)
        uint64 expiry;          // Timestamp batas waktu pengiriman sebelum pembeli berhak meminta refund
        Status status;          // Status saat ini dari listing escrow
    }

    // Referensi kontrak NFT karya seni fisik
    ArthenticNFT public immutable nft;
    // Alamat dompet Gnosis Safe Treasury protokol penampung 1.5% platform fee
    address public treasurySafe;
    // Alamat administrator resolver sengketa (Arbitrator Council)
    address public admin;

    // Penghitung ID listing transaksi berikutnya
    uint256 public nextListingId = 1;
    // Pemetaan data transaksi: listingId => Struktur Listing
    mapping(uint256 => Listing) public listings;

    // Kunci Reentrancy Guard (1: Tidak terkunci, 2: Sedang terkunci)
    uint8 private _locked = 1;

    // --- Konstanta Pembagian Dana Protokol (Basis Points / bps, total 10.000 = 100%) ---
    uint16 public constant ARTIST_ROYALTY_BPS = 500;   // 5.0% Royalti Pencipta Asli (ADR-05 / ERC-2981)
    uint16 public constant PLATFORM_FEE_BPS   = 150;   // 1.5% Biaya Pemeliharaan Protokol & KMS (ADR-05)
    uint16 public constant TOTAL_BPS          = 10000; // 100.0% Penyebut basis points

    // --- Custom Errors untuk Efisiensi Gas ---
    error REENTRANCY();           // Percobaan serangan pemanggilan fungsi berulang (reentrancy)
    error INVALID_PRICE();        // Harga karya seni bernilai 0
    error INVALID_STATUS();       // Status listing tidak valid untuk aksi yang diminta
    error NOT_SELLER();           // Pemanggil bukan penjual karya yang sah
    error NOT_BUYER();            // Pemanggil bukan pembeli yang mendanai escrow
    error EXPIRY_NOT_REACHED();   // Belum melewati batas waktu pengiriman (refund belum diizinkan)
    error PAYMENT_FAILED();       // Transfer aset ETH atau USDC gagal
    error TRANSFER_FAILED();      // Transfer kepemilikan NFT gagal
    error ETH_VALUE_MISMATCH();   // Nilai msg.value ETH tidak cocok dengan harga listing
    error ZERO_ADDRESS();         // Alamat parameter bernilai address(0)

    // --- Event Log Transaksi Escrow ---
    // Dipancarkan saat penjual membuat penawaran baru dan menitipkan NFT
    event ListingCreated(uint256 indexed listingId, uint256 indexed tokenId, address indexed seller, uint256 price, address currency, uint64 expiry);
    // Dipancarkan saat penjual membatalkan penawaran sebelum ada dana masuk
    event ListingCancelled(uint256 indexed listingId);
    // Dipancarkan saat pembeli mengunci dana pembelian di dalam kontrak
    event EscrowFunded(uint256 indexed listingId, address indexed buyer, uint256 amount);
    // Dipancarkan saat karya berhasil diverifikasi secara fisik dan dana dicairkan secara 3-arah
    event ClaimCompleted(
        uint256 indexed listingId,
        uint256 indexed tokenId,
        address indexed buyer,
        uint256 sellerNet,
        uint256 artistRoyalty,
        uint256 protocolFee
    );
    // Dipancarkan saat dana dikembalikan ke pembeli akibat batas waktu kedaluwarsa
    event EscrowRefunded(uint256 indexed listingId, address indexed buyer, uint256 amount);
    // Dipancarkan saat terjadi sengketa fisik/pengiriman
    event EscrowDisputed(uint256 indexed listingId, string reasonURI);
    // Dipancarkan saat sengketa berhasil diputuskan oleh dewan arbiter
    event DisputeResolved(uint256 indexed listingId, bool releasedToSeller);
    // Dipancarkan saat wewenang administratif dialihkan ke alamat baru
    event AdminTransferred(address indexed previousAdmin, address indexed newAdmin);

    // Modifier: Melindungi kontrak dari serangan reentrancy attack
    modifier nonReentrant() {
        if (_locked != 1) revert REENTRANCY();
        _locked = 2;
        _;
        _locked = 1;
    }

    // Konstruktor: Mengikat alamat kontrak NFT, dompet treasury protokol, dan akun admin
    constructor(address _nft, address _treasurySafe, address _admin)
        AttestationVerifier("ArthenticEscrow", "1")
    {
        if (_nft == address(0) || _treasurySafe == address(0) || _admin == address(0)) revert ZERO_ADDRESS();
        nft = ArthenticNFT(_nft);
        treasurySafe = _treasurySafe;
        admin = _admin;
    }

    /// @notice Mewarisi pengecekan peran AccessControl langsung dari kontrak ArthenticNFT
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return nft.hasRole(role, account);
    }

    // =========================================================================
    // FUNGSI 6: createListing() — Penjual Menitipkan NFT ke Escrow & Menentukan Harga
    // =========================================================================
    /// @notice Alur C-01: Penjual mendaftarkan NFT karya seni ke escrow dan menentukan mata uang serta batas waktu pengiriman
    /// @param tokenId ID token NFT karya seni yang dijual
    /// @param currency Alamat token pembayaran (address(0) untuk Base ETH, alamat ERC-20 untuk USDC)
    /// @param price Harga penjualan yang diminta penjual
    /// @param expiry Timestamp batas akhir pengiriman fisik sebelum pembeli berhak meminta pengembalian dana
    /// @return listingId ID unik transaksi escrow yang baru diterbitkan
    function createListing(
        uint256 tokenId,
        address currency,
        uint256 price,
        uint64 expiry
    ) external nonReentrant returns (uint256) {
        // 1. Validasi: Harga tidak boleh nol
        if (price == 0) revert INVALID_PRICE();
        // 2. Validasi: Batas waktu harus di masa depan
        if (expiry <= block.timestamp) revert INVALID_STATUS();

        // 3. Terbitkan ID listing baru
        uint256 listingId = nextListingId++;
        // 4. Catat informasi listing ke dalam penyimpanan state on-chain
        listings[listingId] = Listing({
            tokenId: tokenId,
            seller: msg.sender,
            buyer: address(0),
            currency: currency,
            price: price,
            expiry: expiry,
            status: Status.Listed
        });

        // 5. Pancarkan event ListingCreated
        emit ListingCreated(listingId, tokenId, msg.sender, price, currency, expiry);

        // 6. Ambil alih NFT dari penjual dan titipkan ke kontrak Escrow ini (Checks-Effects-Interactions)
        nft.transferFrom(msg.sender, address(this), tokenId);

        return listingId;
    }

    /// @notice Alur C-03*: Penjual membatalkan penawaran aktif dan mengambil kembali NFT miliknya
    function cancelListing(uint256 listingId) external nonReentrant {
        Listing storage l = listings[listingId];
        // Hanya bisa dibatalkan jika status masih Listed (belum ada dana pembeli yang masuk)
        if (l.status != Status.Listed) revert INVALID_STATUS();
        // Hanya penjual asli atau admin yang berhak membatalkan
        if (l.seller != msg.sender && msg.sender != admin) revert NOT_SELLER();

        l.status = Status.Cancelled;
        emit ListingCancelled(listingId);

        // Kembalikan NFT ke penjual
        nft.transferFrom(address(this), l.seller, l.tokenId);
    }

    // =========================================================================
    // FUNGSI 7: deposit() — Pembeli Menyetor & Mengunci Dana Pembelian
    // =========================================================================
    /// @notice Alur C-04: Pembeli menyetor dana (Base ETH atau USDC) yang dikunci aman di dalam kontrak Escrow
    /// @param listingId ID transaksi escrow yang ingin dibeli
    function deposit(uint256 listingId) external payable nonReentrant {
        Listing storage l = listings[listingId];
        // Pastikan listing berstatus aktif menunggu pembayaran (Listed)
        if (l.status != Status.Listed) revert INVALID_STATUS();

        // Daftarkan pembeli dan ubah status menjadi Funded
        l.buyer = msg.sender;
        l.status = Status.Funded;

        // Proses penguncian dana berdasarkan jenis mata uang (ADR-04)
        if (l.currency == address(0)) {
            // Kasus 1: Native Base ETH — pastikan nominal msg.value tepat sesuai harga
            if (msg.value != l.price) revert ETH_VALUE_MISMATCH();
        } else {
            // Kasus 2: ERC-20 USDC — pastikan msg.value adalah 0 dan transfer dana dari dompet pembeli
            if (msg.value != 0) revert ETH_VALUE_MISMATCH();
            bool success = IERC20(l.currency).transferFrom(msg.sender, address(this), l.price);
            if (!success) revert PAYMENT_FAILED();
        }

        emit EscrowFunded(listingId, msg.sender, l.price);
    }

    // =========================================================================
    // FUNGSI 8: claim() — Melepas NFT & Dana Pasca-Verifikasi Fisik (SUN CMAC Valid)
    // =========================================================================
    /// @notice Alur C-06: Pembeli memindai fisik karya seni saat tiba, menyerahkan attestation EIP-712 dari Protocol Node
    /// Menerapkan Pembagian Atomik 3-Arah (ADR-05): 93.5% Penjual, 5.0% Seniman, 1.5% Treasury
    /// @param listingId ID transaksi escrow yang dikonfirmasi
    /// @param a Struktur Attestation verifikasi fisik dari Protocol Node
    /// @param sig Tanda tangan kriptografi secp256k1 Protocol Node
    function claim(
        uint256 listingId,
        Attestation calldata a,
        bytes calldata sig
    ) external nonReentrant {
        Listing storage l = listings[listingId];
        // 1. Pastikan transaksi telah didanai sebelumnya
        if (l.status != Status.Funded) revert INVALID_STATUS();
        // 2. Pastikan yang melakukan konfirmasi adalah pembeli sah atau admin
        if (msg.sender != l.buyer && msg.sender != admin) revert NOT_BUYER();
        // 3. Pastikan attestation sesuai dengan tokenId karya seni yang diperjualbelikan
        if (a.tokenId != l.tokenId) revert INVALID_STATUS();

        // 4. Verifikasi keabsahan attestation kriptografis Protocol Node on-chain
        _verifyAttestation(a, sig, false);

        // 5. Ubah status listing menjadi Completed (Selesai Sukses)
        l.status = Status.Completed;

        // 6. Hitung pembagian dana 3-arah ADR-05
        (address artist, uint256 royalty) = nft.royaltyInfo(l.tokenId, l.price);
        if (artist == address(0)) artist = nft.tokenArtist(l.tokenId);

        uint256 artistRoyalty = royalty > 0 ? royalty : (l.price * ARTIST_ROYALTY_BPS) / TOTAL_BPS; // 5.0%
        uint256 protocolFee   = (l.price * PLATFORM_FEE_BPS) / TOTAL_BPS;                            // 1.5%
        uint256 sellerNet     = l.price - artistRoyalty - protocolFee;                               // 93.5%

        emit ClaimCompleted(listingId, l.tokenId, l.buyer, sellerNet, artistRoyalty, protocolFee);

        // 7. Transfer dana sesuai mata uang
        if (l.currency == address(0)) {
            // Penyaluran Base ETH native
            (bool s1, ) = l.seller.call{value: sellerNet}("");
            (bool s2, ) = artist.call{value: artistRoyalty}("");
            (bool s3, ) = treasurySafe.call{value: protocolFee}("");
            if (!s1 || !s2 || !s3) revert PAYMENT_FAILED();
        } else {
            // Penyaluran token ERC-20 USDC
            bool s1 = IERC20(l.currency).transfer(l.seller, sellerNet);
            bool s2 = IERC20(l.currency).transfer(artist, artistRoyalty);
            bool s3 = IERC20(l.currency).transfer(treasurySafe, protocolFee);
            if (!s1 || !s2 || !s3) revert PAYMENT_FAILED();
        }

        // 8. Lepaskan dan kirim token NFT kepemilikan resmi kepada Pembeli
        nft.transferFrom(address(this), l.buyer, l.tokenId);
    }

    // =========================================================================
    // FUNGSI 9: refund() — Pengembalian Dana Otomatis jika Melewati Batas Waktu
    // =========================================================================
    /// @notice Alur C-12: Mengembalikan 100% dana ke pembeli jika lukisan fisik tidak pernah terkirim/dikonfirmasi hingga expiry
    /// @param listingId ID transaksi escrow yang telah kedaluwarsa
    function refund(uint256 listingId) external nonReentrant {
        Listing storage l = listings[listingId];
        // 1. Pastikan escrow dalam status terdanai (Funded)
        if (l.status != Status.Funded) revert INVALID_STATUS();
        // 2. Pastikan waktu saat ini telah melewati batas expiry yang disepakati
        if (block.timestamp <= l.expiry) revert EXPIRY_NOT_REACHED();

        // 3. Ubah status transaksi menjadi Refunded
        l.status = Status.Refunded;
        emit EscrowRefunded(listingId, l.buyer, l.price);

        // 4. Kembalikan 100% dana kepada Pembeli
        if (l.currency == address(0)) {
            (bool ok, ) = l.buyer.call{value: l.price}("");
            if (!ok) revert PAYMENT_FAILED();
        } else {
            bool ok = IERC20(l.currency).transfer(l.buyer, l.price);
            if (!ok) revert PAYMENT_FAILED();
        }

        // 5. Kembalikan NFT dari penampungan escrow kembali kepada Penjual
        nft.transferFrom(address(this), l.seller, l.tokenId);
    }

    // =========================================================================
    // FUNGSI PENDUKUNG: dispute() — Membekukan Escrow Saat Terjadi Masalah Transit
    // =========================================================================
    /// @notice Alur C-10: Membekukan pelepasan dana jika terjadi klaim kerusakan kanvas atau kurir bermasalah
    function dispute(uint256 listingId, string calldata reasonURI) external nonReentrant {
        Listing storage l = listings[listingId];
        if (l.status != Status.Funded) revert INVALID_STATUS();
        if (msg.sender != l.buyer && msg.sender != l.seller && msg.sender != admin) revert ACCESS_DENIED();

        l.status = Status.Disputed;
        emit EscrowDisputed(listingId, reasonURI);
    }

    // =========================================================================
    // FUNGSI PENDUKUNG: resolveDispute() — Penyelesaian Sengketa oleh Dewan Arbiter
    // =========================================================================
    /// @notice Alur C-11: Keputusan dewan penengah apakah dana dicairkan ke penjual atau direfund ke pembeli
    function resolveDispute(uint256 listingId, bool releaseToSeller) external nonReentrant {
        if (msg.sender != admin) revert ACCESS_DENIED();
        Listing storage l = listings[listingId];
        if (l.status != Status.Disputed) revert INVALID_STATUS();

        emit DisputeResolved(listingId, releaseToSeller);

        if (releaseToSeller) {
            // Sengketa dimenangkan penjual: Selesaikan pembayaran 3-arah & kirim NFT ke pembeli
            l.status = Status.Completed;
            (address artist, uint256 royalty) = nft.royaltyInfo(l.tokenId, l.price);
            if (artist == address(0)) artist = nft.tokenArtist(l.tokenId);
            uint256 artistRoyalty = royalty > 0 ? royalty : (l.price * ARTIST_ROYALTY_BPS) / TOTAL_BPS;
            uint256 protocolFee   = (l.price * PLATFORM_FEE_BPS) / TOTAL_BPS;
            uint256 sellerNet     = l.price - artistRoyalty - protocolFee;

            if (l.currency == address(0)) {
                (bool s1, ) = l.seller.call{value: sellerNet}("");
                (bool s2, ) = artist.call{value: artistRoyalty}("");
                (bool s3, ) = treasurySafe.call{value: protocolFee}("");
                if (!s1 || !s2 || !s3) revert PAYMENT_FAILED();
            } else {
                if (!IERC20(l.currency).transfer(l.seller, sellerNet)) revert PAYMENT_FAILED();
                if (!IERC20(l.currency).transfer(artist, artistRoyalty)) revert PAYMENT_FAILED();
                if (!IERC20(l.currency).transfer(treasurySafe, protocolFee)) revert PAYMENT_FAILED();
            }
            nft.transferFrom(address(this), l.buyer, l.tokenId);
        } else {
            // Sengketa dimenangkan pembeli: Kembalikan dana 100% ke pembeli & NFT ke penjual
            l.status = Status.Refunded;
            if (l.currency == address(0)) {
                (bool ok, ) = l.buyer.call{value: l.price}("");
                if (!ok) revert PAYMENT_FAILED();
            } else {
                if (!IERC20(l.currency).transfer(l.buyer, l.price)) revert PAYMENT_FAILED();
            }
            nft.transferFrom(address(this), l.seller, l.tokenId);
        }
    }

    /// @notice Mengalihkan hak administrasi sengketa ke alamat baru (misalnya Gnosis Safe multisig)
    function transferAdmin(address newAdmin) external {
        if (msg.sender != admin) revert ACCESS_DENIED();
        if (newAdmin == address(0)) revert ZERO_ADDRESS();
        address oldAdmin = admin;
        admin = newAdmin;
        emit AdminTransferred(oldAdmin, newAdmin);
    }
}
