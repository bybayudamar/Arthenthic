// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Mengimpor library daftar peran (Roles.sol)
import {Roles} from "./Roles.sol";
// Mengimpor kontrak induk AttestationVerifier untuk validasi EIP-712
import {AttestationVerifier} from "./AttestationVerifier.sol";

/// @title ArthenticNFT
/// @notice Kontrak pintar inti identitas karya seni fisik (ERC-721 + ERC-2981) di Base L2.
/// Menerapkan penegakan kriptografis ketat:
/// - SC-CHIP-01: Satu chip fisik NTAG 424 DNA tidak dapat diikat ke dua token berbeda (Anti-Kloning).
/// - SC-GEN-01: Hash vektor biometrik genesis bersifat kekal/abadi (Immutable) sekali dicetak.
/// - ADR-02 / B-07: Co-signature seniman wajib divalidasi via EIP-712 sebelum minting on-chain.
/// - ADR-03 / E-07*: Pembaruan kondisi pasca-restorasi wajib mengantongi izin tanda tangan EIP-712 pemilik karya.
/// - F-05: Pemulihan chip rusak membutuhkan persetujuan multisig 3-of-3 (Kolektor, Seniman, Verifier).
contract ArthenticNFT is AttestationVerifier {
    // --- Metadata Standar ERC-721 ---
    string public name = "Arthentic Physical Artwork";   // Nama koleksi NFT
    string public symbol = "ARTH";                        // Simbol ticker token

    // --- Manajemen Peran (Access Control) ---
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;   // Identifier peran administrator utama
    mapping(bytes32 => mapping(address => bool)) private _roles; // Pemetaan peran akun: role => (address => bool)

    // --- State Invariants & Penyimpanan Data Phygital ---
    mapping(bytes32 => bool) public chipBound;              // SC-CHIP-01: Melacak apakah chipIdHash sudah terikat ke suatu karya
    mapping(uint256 => bytes32) public genesisHash;         // SC-GEN-01: Hash baseline fitur fisik & LiDAR awal (tidak dapat diubah)
    mapping(uint256 => bytes32) public activeChip;          // Hash chipIdHash NFC NTAG 424 DNA yang saat ini aktif terpasang
    mapping(uint256 => bool) public destroyed;              // Status bendera jika fisik karya seni dilaporkan hancur/hilang
    mapping(uint256 => address) public tokenArtist;         // Alamat dompet seniman pencipta karya yang sah
    mapping(uint256 => string) private _tokenURIs;          // Pemetaan tokenId ke URI metadata terdesentralisasi (Arweave/IPFS)
    mapping(uint256 => address) private _owners;            // Pemetaan tokenId ke pemilik akun saat ini
    mapping(address => uint256) private _balances;          // Jumlah saldo kepemilikan token per alamat
    mapping(uint256 => address) private _tokenApprovals;    // Akun yang diberi wewenang transfer untuk tokenId tertentu
    mapping(address => mapping(address => bool)) private _operatorApprovals; // Operator yang disetujui untuk semua token pemilik

    // --- Standar Royalti ERC-2981 (500 bps = 5.0% Default) ---
    uint96 public constant DEFAULT_ROYALTY_BPS = 500;       // Persentase royalti baku (5.0%)
    mapping(uint256 => address) public royaltyRecipient;    // Alamat penerima royalti untuk masing-masing karya
    mapping(uint256 => uint96) public royaltyBps;           // Besaran basis points royalti per karya

    // --- Circuit Breaker & Penomoran Token ---
    bool public paused;                                     // Flag status darurat (pause) untuk menghentikan transaksi
    uint256 public nextTokenId = 1;                         // Penghitung otomatis (auto-increment) ID token berikutnya

    // --- EIP-712 TypeHashes untuk Verifikasi Tanda Tangan ---
    // TypeHash untuk berkas intake seniman awal (Genesis Dossier)
    bytes32 public constant GENESIS_DOSSIER_TYPEHASH = keccak256(
        "GenesisDossier(address artist,bytes32 genesisVectorHash,bytes32 chipIdHash,bytes32 metadataHash)"
    );
    // TypeHash untuk persetujuan pemilik saat pencatatan restorasi kondisi fisik
    bytes32 public constant OWNER_CONSENT_TYPEHASH = keccak256(
        "OwnerConsent(uint256 tokenId,bytes32 newVectorHash,bytes32 noteHash,uint256 nonce)"
    );
    // TypeHash untuk persetujuan multisig penggantian chip fisik yang rusak
    bytes32 public constant CHIP_REPLACEMENT_TYPEHASH = keccak256(
        "ChipReplacementApproval(uint256 tokenId,bytes32 oldChipIdHash,bytes32 newChipIdHash,bytes32 opticalDigest)"
    );

    // --- Custom Errors untuk Efisiensi Biaya Gas ---
    error GENESIS_IMMUTABLE();          // Upaya mengubah genesis hash yang sudah kekal
    error CHIP_ALREADY_BOUND();         // Chip NFC sudah pernah terdaftar pada karya seni lain
    error ARTIST_ROLE_REQUIRED();       // Akun seniman belum memiliki ARTIST_ROLE resmi
    error ARTIST_COSIGN_INVALID();      // Tanda tangan EIP-712 co-sign seniman tidak cocok
    error OWNER_CONSENT_INVALID();      // Tanda tangan persetujuan pemilik karya tidak cocok
    error CHIP_APPROVAL_INVALID(uint8 index); // Salah satu persetujuan multisig (0:Kolektor, 1:Seniman, 2:Verifier) tidak sah
    error ARTWORK_DESTROYED();          // Karya telah berstatus fisik hancur, transaksi diblokir
    error CONTRACT_PAUSED();            // Kontrak sedang dalam mode jeda darurat
    error NOT_OWNER_OR_APPROVED();      // Pemanggil bukan pemilik atau operator yang disetujui
    error INVALID_TOKEN();              // ID token tidak ditemukan atau alamat tujuan tidak valid

    // --- Event Log Provenance On-Chain ---
    // Dipancarkan saat karya seni pertama kali berhasil dicetak dan diikat ke chip
    event GenesisRegistered(
        uint256 indexed tokenId,
        address indexed artist,
        address indexed verifier,
        bytes32 genesisHash,
        bytes32 chipIdHash,
        string metadataURI
    );
    // Dipancarkan saat konservator memperbarui catatan fisik pasca-restorasi
    event ConditionUpdated(
        uint256 indexed tokenId,
        bytes32 newVectorHash,
        address indexed conservator,
        string noteURI,
        uint256 timestamp
    );
    // Dipancarkan saat chip fisik lama diganti dengan chip baru melalui multisig 3-of-3
    event ChipReplaced(
        uint256 indexed tokenId,
        bytes32 oldChipIdHash,
        bytes32 newChipIdHash,
        address indexed verifier,
        uint256 timestamp
    );
    // Dipancarkan setiap kali verifikasi fisik (L1 Tap atau L2 Scan) dicatat on-chain
    event VerificationRecorded(
        uint256 indexed tokenId,
        uint16 similarityBps,
        address indexed recorder,
        uint256 timestamp
    );
    // Dipancarkan saat karya seni dilaporkan rusak permanen atau musnah
    event ArtworkDestroyed(uint256 indexed tokenId, string proofURI, uint256 timestamp);
    // Event Access Control
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    event Paused(address account);
    event Unpaused(address account);
    // Event ERC-721 Standar
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // Modifier: Memastikan sistem tidak sedang dalam mode jeda darurat (Circuit Breaker)
    modifier whenNotPaused() {
        if (paused) revert CONTRACT_PAUSED();
        _;
    }

    // Modifier: Membatasi eksekusi hanya untuk akun dengan peran tertentu atau Default Admin
    modifier onlyRole(bytes32 role) {
        if (!_roles[role][msg.sender] && !_roles[DEFAULT_ADMIN_ROLE][msg.sender]) {
            revert ACCESS_DENIED();
        }
        _;
    }

    // Konstruktor: Menginisialisasi nama EIP-712 Domain, akun Admin, dan Protocol Node penandatangan
    constructor(address initialAdmin, address protocolNode)
        AttestationVerifier("ArthenticNFT", "1")
    {
        _roles[DEFAULT_ADMIN_ROLE][initialAdmin] = true;
        _roles[Roles.PROTOCOL_NODE_ROLE][protocolNode] = true;
        emit RoleGranted(DEFAULT_ADMIN_ROLE, initialAdmin, msg.sender);
        emit RoleGranted(Roles.PROTOCOL_NODE_ROLE, protocolNode, msg.sender);
    }

    // --- Implementasi AccessControl ---
    /// @notice Memeriksa apakah suatu akun memiliki peran spesifik
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role][account] || _roles[DEFAULT_ADMIN_ROLE][account];
    }

    /// @notice Memberikan peran kepada suatu akun (hanya oleh Default Admin)
    function grantRole(bytes32 role, address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _roles[role][account] = true;
        emit RoleGranted(role, account, msg.sender);
    }

    /// @notice Mencabut peran dari suatu akun (hanya oleh Default Admin)
    function revokeRole(bytes32 role, address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _roles[role][account] = false;
        emit RoleRevoked(role, account, msg.sender);
    }

    // --- Circuit Breaker / Emergency Stop (J-01) ---
    /// @notice Mengaktifkan status pause darurat jika terdeteksi anomali pada sistem
    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        paused = true;
        emit Paused(msg.sender);
    }

    /// @notice Membuka kembali status pause darurat setelah anomali terselesaikan
    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        paused = false;
        emit Unpaused(msg.sender);
    }

    // =========================================================================
    // FUNGSI 1: genesisMint() — Mencetak NFT Karya Baru & Mengikat Fisik ke Digital
    // =========================================================================
    /// @notice Dipanggil oleh Galeri Verifier terakreditasi untuk mendaftarkan karya seni baru
    /// @param artist Alamat dompet seniman pencipta karya yang memiliki ARTIST_ROLE
    /// @param genesisVectorHash Hash 32-byte dari data biometrik serat optik & LiDAR awal kanvas
    /// @param chipIdHash Hash 32-byte dari UID chip NFC NXP NTAG 424 DNA fisik
    /// @param metadataURI Tautan URI desentralisasi (Arweave/IPFS) berisi metadata dan foto resolusi tinggi
    /// @param artistSig Tanda tangan kriptografi EIP-712 seniman sebagai bukti persetujuan pencetakan karya
    /// @return tokenId ID token ERC-721 yang baru diterbitkan
    function genesisMint(
        address artist,
        bytes32 genesisVectorHash,
        bytes32 chipIdHash,
        string calldata metadataURI,
        bytes calldata artistSig
    ) external whenNotPaused onlyRole(Roles.VERIFIER_ROLE) returns (uint256) {
        // 1. Validasi: Seniman harus memiliki peran ARTIST_ROLE
        if (!hasRole(Roles.ARTIST_ROLE, artist)) revert ARTIST_ROLE_REQUIRED();

        // 2. SC-CHIP-01: Pastikan chip fisik belum pernah didaftarkan pada karya seni lain sebelumnya
        if (chipBound[chipIdHash]) revert CHIP_ALREADY_BOUND();

        // 3. Validasi: Hash biometrik awal tidak boleh kosong
        if (genesisVectorHash == bytes32(0)) revert INVALID_TOKEN();

        // 4. ADR-02: Verifikasi co-signature seniman via EIP-712 pada digest dossier genesis
        bytes32 dossierDigest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        GENESIS_DOSSIER_TYPEHASH,
                        artist,
                        genesisVectorHash,
                        chipIdHash,
                        keccak256(bytes(metadataURI))
                    )
                )
            )
        );
        address recoveredArtist = _recoverSigner(dossierDigest, artistSig);
        if (recoveredArtist != artist) revert ARTIST_COSIGN_INVALID();

        // 5. Terbitkan ID token baru
        uint256 tokenId = nextTokenId++;

        // 6. SC-GEN-01 & SC-CHIP-01: Ikat hash vektor fisik dan chip NFC ke tokenId secara permanen
        genesisHash[tokenId] = genesisVectorHash;
        activeChip[tokenId] = chipIdHash;
        chipBound[chipIdHash] = true;
        tokenArtist[tokenId] = artist;
        _tokenURIs[tokenId] = metadataURI;

        // 7. Konfigurasi royalti ERC-2981: 5.0% (500 bps) diarahkan langsung ke seniman
        royaltyRecipient[tokenId] = artist;
        royaltyBps[tokenId] = DEFAULT_ROYALTY_BPS;

        // 8. Pancarkan event pendaftaran genesis on-chain
        emit GenesisRegistered(tokenId, artist, msg.sender, genesisVectorHash, chipIdHash, metadataURI);

        // 9. Cetak (mint) token ERC-721 langsung ke alamat dompet seniman
        _mint(artist, tokenId);

        return tokenId;
    }

    // =========================================================================
    // FUNGSI 2: recordVerification() — Mencatat Hasil Verifikasi Fisik On-Chain
    // =========================================================================
    /// @notice Dipanggil oleh kolektor/pembeli setelah memindai chip NFC atau memindai serat LiDAR
    /// @param a Struktur Attestation EIP-712 dari Protocol Node
    /// @param sig Tanda tangan kriptografi dari Protocol Node penandatangan
    function recordVerification(Attestation calldata a, bytes calldata sig) external whenNotPaused {
        // 1. Pastikan karya tidak dalam status musnah
        if (destroyed[a.tokenId]) revert ARTWORK_DESTROYED();

        // 2. Validasi keaslian tanda tangan attestation node (Level 1 tap atau Level 2 scan)
        _verifyAttestation(a, sig, false);

        // 3. Catat event verifikasi sukses beserta skor kemiripan ke buku besar on-chain
        emit VerificationRecorded(a.tokenId, a.similarityBps, msg.sender, block.timestamp);
    }

    // =========================================================================
    // FUNGSI 3: updateCondition() — Mencatat Laporan Restorasi & Kondisi Fisik Baru
    // =========================================================================
    /// @notice Dipanggil oleh konservator terakreditasi pasca-restorasi karya seni
    /// @param tokenId ID token karya seni yang direstorasi
    /// @param newVectorHash Hash vektor biometrik terbaru pasca pembersihan atau perbaikan
    /// @param noteURI Tautan laporan detail restorasi yang tersimpan di Arweave/IPFS
    /// @param ownerConsentSig Tanda tangan EIP-712 pemilik karya yang memberikan persetujuan resmi
    function updateCondition(
        uint256 tokenId,
        bytes32 newVectorHash,
        string calldata noteURI,
        bytes calldata ownerConsentSig
    ) external whenNotPaused onlyRole(Roles.CONSERVATOR_ROLE) {
        // 1. Validasi: Karya tidak boleh berstatus hancur
        if (destroyed[tokenId]) revert ARTWORK_DESTROYED();
        if (newVectorHash == bytes32(0)) revert INVALID_TOKEN();
        address owner = ownerOf(tokenId);

        // 2. ADR-03 (E-07*): Verifikasi persetujuan bertanda tangan EIP-712 dari pemilik karya
        bytes32 consentDigest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        OWNER_CONSENT_TYPEHASH,
                        tokenId,
                        newVectorHash,
                        keccak256(bytes(noteURI)),
                        tokenId
                    )
                )
            )
        );
        address recoveredOwner = _recoverSigner(consentDigest, ownerConsentSig);
        if (recoveredOwner != owner) revert OWNER_CONSENT_INVALID();

        // 3. Catatan: genesisHash[tokenId] tetap utuh dan tidak pernah ditimpa (prinsip keabadian data asal)
        // 4. Pancarkan event pembaruan kondisi fisik
        emit ConditionUpdated(tokenId, newVectorHash, msg.sender, noteURI, block.timestamp);
    }

    // =========================================================================
    // FUNGSI 4: replaceChip() — Mengganti Chip NFC Rusak via Multisig 3-of-3
    // =========================================================================
    /// @notice Mengganti chip NFC fisik jika rusak atau tamper loop putus, dengan syarat 3 pihak co-sign
    /// @param tokenId ID token karya seni
    /// @param newChipIdHash Hash dari chip NFC NTAG 424 DNA pengganti yang baru
    /// @param optical Attestation verifikasi biometrik optik LiDAR (skor wajib >= 88.0%)
    /// @param nodeSig Tanda tangan EIP-712 Protocol Node pada attestation optik
    /// @param approvals Tiga tanda tangan persetujuan: [0]=Kolektor (Pemilik), [1]=Seniman, [2]=Verifier
    function replaceChip(
        uint256 tokenId,
        bytes32 newChipIdHash,
        Attestation calldata optical,
        bytes calldata nodeSig,
        bytes[3] calldata approvals
    ) external whenNotPaused onlyRole(Roles.VERIFIER_ROLE) {
        if (destroyed[tokenId]) revert ARTWORK_DESTROYED();
        // Pastikan chip pengganti belum pernah dipakai pada karya mana pun
        if (chipBound[newChipIdHash]) revert CHIP_ALREADY_BOUND();
        bytes32 oldChip = activeChip[tokenId];

        // 1. Wajib lolos gerbang optik biometrik LiDAR >= 8800 bps (88.0%) untuk membuktikan fisik kanvas sama
        _verifyAttestation(optical, nodeSig, true);

        // 2. Hitung digest penggantian chip EIP-712
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        CHIP_REPLACEMENT_TYPEHASH,
                        tokenId,
                        oldChip,
                        newChipIdHash,
                        optical.sunDigest
                    )
                )
            )
        );

        // 3. Verifikasi Persetujuan 1/3: Pemilik karya saat ini (Kolektor)
        if (_recoverSigner(digest, approvals[0]) != ownerOf(tokenId)) revert CHIP_APPROVAL_INVALID(0);

        // 4. Verifikasi Persetujuan 2/3: Seniman pencipta karya asli
        address artist = tokenArtist[tokenId];
        if (_recoverSigner(digest, approvals[1]) != artist) revert CHIP_APPROVAL_INVALID(1);

        // 5. Verifikasi Persetujuan 3/3: Galeri Verifier terakreditasi (pemanggil fungsi)
        if (_recoverSigner(digest, approvals[2]) != msg.sender) revert CHIP_APPROVAL_INVALID(2);

        // 6. Lepas ikatan chip lama dan ikat chip baru ke token karya seni
        chipBound[oldChip] = false;
        chipBound[newChipIdHash] = true;
        activeChip[tokenId] = newChipIdHash;

        // 7. Pancarkan event ChipReplaced on-chain
        emit ChipReplaced(tokenId, oldChip, newChipIdHash, msg.sender, block.timestamp);
    }

    // =========================================================================
    // FUNGSI 5: markDestroyed() — Menandai Karya Seni Telah Musnah / Hancur
    // =========================================================================
    /// @notice Menandai karya seni hancur akibat kebakaran, kecelakaan transit, atau musibah permanen
    /// @param tokenId ID token karya seni
    /// @param proofURI Tautan berita acara kepolisian / dokumen klaim asuransi resmi
    function markDestroyed(uint256 tokenId, string calldata proofURI)
        external
        onlyRole(Roles.VERIFIER_ROLE)
    {
        if (_owners[tokenId] == address(0)) revert INVALID_TOKEN();
        // Set flag status hancur: mencegah seluruh aktivitas transfer, verifikasi, dan escrow masa depan
        destroyed[tokenId] = true;
        emit ArtworkDestroyed(tokenId, proofURI, block.timestamp);
    }

    // --- Standar Royalti ERC-2981 ---
    /// @notice Mengembalikan informasi penerima dan jumlah royalti seniman pada pasar sekunder
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount)
    {
        receiver = royaltyRecipient[tokenId];
        if (receiver == address(0)) receiver = tokenArtist[tokenId];
        uint96 bps = royaltyBps[tokenId] > 0 ? royaltyBps[tokenId] : DEFAULT_ROYALTY_BPS;
        royaltyAmount = (salePrice * bps) / 10000;
    }

    // --- Implementasi Inti Standar ERC-721 ---
    /// @notice Mendapatkan alamat pemilik resmi dari suatu tokenId
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        if (owner == address(0)) revert INVALID_TOKEN();
        return owner;
    }

    /// @notice Mengambil tautan metadata URI dari karya seni
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        if (_owners[tokenId] == address(0)) revert INVALID_TOKEN();
        return _tokenURIs[tokenId];
    }

    /// @notice Mengetahui jumlah total karya seni yang dimiliki oleh suatu alamat
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /// @notice Melakukan transfer kepemilikan token dari satu alamat ke alamat lain
    function transferFrom(address from, address to, uint256 tokenId) public whenNotPaused {
        if (destroyed[tokenId]) revert ARTWORK_DESTROYED();
        address owner = ownerOf(tokenId);
        if (from != owner) revert NOT_OWNER_OR_APPROVED();
        if (to == address(0)) revert INVALID_TOKEN();
        if (msg.sender != owner && msg.sender != _tokenApprovals[tokenId] && !_operatorApprovals[owner][msg.sender]) {
            revert NOT_OWNER_OR_APPROVED();
        }

        delete _tokenApprovals[tokenId];
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /// @notice Memberikan izin kepada pihak ketiga untuk mengelola transfer tokenId ini
    function approve(address to, uint256 tokenId) public whenNotPaused {
        address owner = ownerOf(tokenId);
        if (msg.sender != owner && !_operatorApprovals[owner][msg.sender]) revert NOT_OWNER_OR_APPROVED();
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /// @notice Memberikan izin kepada operator untuk mengelola seluruh token milik pemanggil
    function setApprovalForAll(address operator, bool approved) public whenNotPaused {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /// @notice Fungsi internal untuk mencetak token baru
    function _mint(address to, uint256 tokenId) internal {
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
    }
}
