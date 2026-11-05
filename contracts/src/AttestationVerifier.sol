// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Mengimpor konstanta peran protokol (PROTOCOL_NODE_ROLE) dari Roles.sol
import {Roles} from "./Roles.sol";

/// @title AttestationVerifier
/// @notice Kontrak abstrak verifikator data terstruktur EIP-712 yang diwariskan oleh ArthenticNFT dan ArthenticEscrow.
/// Berfungsi memvalidasi tanda tangan kriptografi Protocol Node HSM/KMS, batas kedaluwarsa waktu (deadline),
/// perlindungan anti-replay nonce, dan ambang batas kesamaan optik LiDAR minimal 88.0% (8800 bps).
abstract contract AttestationVerifier {
    // Ambang batas minimal kesamaan kosinus biometrik serat kain (8800 bps = 88.0%) sesuai ADR-06 & D-06
    uint16 public constant MIN_SIMILARITY_BPS = 8800;

    // Struktur data Attestation yang diterbitkan oleh Protocol Node KMS/HSM
    struct Attestation {
        uint256 tokenId;        // ID unik token karya seni yang diverifikasi
        bytes32 sunDigest;      // Hash dari payload tap NFC: keccak256(abi.encodePacked(uid, ":", ctr, ":", cmac))
        uint16 similarityBps;   // Nilai kesamaan serat optik: 0 untuk L1 NFC Tap; 8800..10000 untuk L2 LiDAR Scan
        uint256 deadline;       // Batas waktu timestamp kedaluwarsa (misalnya: block.timestamp + 300 detik)
        bytes32 nonce;          // Nilai nonce acak sekali pakai untuk mencegah serangan pengulangan (anti-replay)
    }

    // TypeHash EIP-712 untuk struktur Attestation di atas
    bytes32 public constant ATTESTATION_TYPEHASH = keccak256(
        "Attestation(uint256 tokenId,bytes32 sunDigest,uint16 similarityBps,uint256 deadline,bytes32 nonce)"
    );

    // EIP-712 Domain Separator yang mengikat tanda tangan ke nama kontrak, versi, chain ID, dan alamat kontrak spesifik
    bytes32 public immutable DOMAIN_SEPARATOR;

    // Pemetaan untuk mencatat nonce yang telah digunakan agar tidak dapat dipakai ulang (Replay Protection)
    mapping(bytes32 => bool) public usedNonce;

    // --- Definisi Custom Errors untuk Penghematan Gas ---
    error ATTESTATION_EXPIRED();          // Terjadi jika waktu verifikasi melewati batas deadline
    error REPLAY();                       // Terjadi jika nonce yang sama dikirimkan lebih dari satu kali
    error SIMILARITY_BELOW_THRESHOLD();   // Terjadi jika skor kemiripan optik di bawah 88.0% pada verifikasi L2
    error INVALID_SIGNER();               // Terjadi jika penandatangan bukan pemegang PROTOCOL_NODE_ROLE yang sah
    error ACCESS_DENIED();                // Terjadi jika pemanggil tidak memiliki wewenang peran yang sesuai

    // Event yang dipancarkan saat sebuah attestation berhasil divalidasi di on-chain
    event AttestationVerified(
        uint256 indexed tokenId,
        bytes32 indexed nonce,
        uint16 similarityBps,
        address signer
    );

    // Konstruktor: Menghitung dan menyimpan DOMAIN_SEPARATOR EIP-712 saat kontrak dideploy
    constructor(string memory name, string memory version) {
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                block.chainid,
                address(this)
            )
        );
    }

    /// @notice Metode virtual untuk memeriksa peran akun, diimplementasikan oleh kontrak turunan (AccessControl)
    function hasRole(bytes32 role, address account) public view virtual returns (bool);

    /// @notice Fungsi internal untuk memverifikasi keabsahan EIP-712 Attestation dari Protocol Node
    /// @param a Data struktur attestation yang dikirimkan pemanggil
    /// @param sig Tanda tangan kriptografi secp256k1 (65 byte: r, s, v) dari Protocol Node
    /// @param requireOptical Boolean: true jika membutuhkan uji biometrik optik Level 2 (skor >= 8800 bps)
    /// @return signer Alamat dompet Protocol Node yang memvalidasi dan menandatangani attestation
    function _verifyAttestation(
        Attestation calldata a,
        bytes calldata sig,
        bool requireOptical
    ) internal returns (address signer) {
        // 1. Periksa apakah attestation telah melewati batas waktu berlaku
        if (block.timestamp > a.deadline) revert ATTESTATION_EXPIRED();

        // 2. Periksa apakah nonce pernah digunakan sebelumnya (mencegah replay attack)
        if (usedNonce[a.nonce]) revert REPLAY();

        // 3. Jika mensyaratkan verifikasi optik L2, pastikan skor kemiripan memenuhi ambang batas minimal
        if (requireOptical && a.similarityBps < MIN_SIMILARITY_BPS) revert SIMILARITY_BELOW_THRESHOLD();

        // 4. Hitung hash representasi struktur data EIP-712
        bytes32 structHash = keccak256(
            abi.encode(
                ATTESTATION_TYPEHASH,
                a.tokenId,
                a.sunDigest,
                a.similarityBps,
                a.deadline,
                a.nonce
            )
        );

        // 5. Gabungkan prefix EIP-712 (\x19\x01), DOMAIN_SEPARATOR, dan structHash
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash)
        );

        // 6. Pulihkan alamat publik penandatangan dari signature
        signer = _recoverSigner(digest, sig);

        // 7. Pastikan penandatangan adalah node protokol resmi yang memiliki PROTOCOL_NODE_ROLE
        if (!hasRole(Roles.PROTOCOL_NODE_ROLE, signer)) revert INVALID_SIGNER();

        // 8. Tandai nonce sebagai telah terpakai (State change sebelum interaksi lain)
        usedNonce[a.nonce] = true;

        // 9. Pancarkan event verifikasi sukses
        emit AttestationVerified(a.tokenId, a.nonce, a.similarityBps, signer);
    }

    /// @notice Fungsi internal untuk mengekstrak alamat penandatangan dari tanda tangan ECDSA 65 byte
    /// Dilengkapi proteksi malleability signature EIP-2 (low-s rule)
    function _recoverSigner(bytes32 hash, bytes calldata sig) internal pure returns (address) {
        // Panjang signature wajib tepat 65 byte (r: 32 byte, s: 32 byte, v: 1 byte)
        if (sig.length != 65) revert INVALID_SIGNER();
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            // Membaca 32 byte pertama dari payload signature untuk komponen 'r'
            r := calldataload(sig.offset)
            // Membaca 32 byte kedua dari payload signature untuk komponen 's'
            s := calldataload(add(sig.offset, 32))
            // Membaca 1 byte terakhir dari payload signature untuk komponen 'v'
            v := byte(0, calldataload(add(sig.offset, 64)))
        }
        // Penegakan EIP-2: Pastikan nilai 's' berada di paruh bawah kurva eliptik secp256k1 (anti-malleability)
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) revert INVALID_SIGNER();
        // Nilai recovery identifier 'v' yang sah pada Ethereum adalah 27 atau 28
        if (v != 27 && v != 28) revert INVALID_SIGNER();
        // Pulihkan alamat dompet publik menggunakan built-in ecrecover
        address recovered = ecrecover(hash, v, r, s);
        // Pastikan alamat yang dipulihkan bukan alamat nol (gagal pulih)
        if (recovered == address(0)) revert INVALID_SIGNER();
        return recovered;
    }
}
