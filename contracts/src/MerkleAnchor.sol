// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Mengimpor konstanta peran (ANCHORER_ROLE) dari Roles.sol
import {Roles} from "./Roles.sol";

/// @title MerkleAnchor
/// @notice Kontrak penjangkaran (settlement anchor) di Ethereum L1 untuk mencatat batch event provenance dari Base L2 (H-05 / SD-10).
/// Berfungsi menyimpan Merkle Root berkala yang merangkum ribuan transaksi verifikasi dan kepemilikan fisik di Layer 2,
/// sehingga setiap bukti keaslian karya seni dapat diverifikasi langsung terhadap keamanan konsensus Ethereum Layer 1.
contract MerkleAnchor {
    // Peran Admin Utama (mengikuti standar AccessControl default OpenZeppelin: 0x00)
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    // Pemetaan multi-peran: role => (account => boolean hasRole)
    mapping(bytes32 => mapping(address => bool)) private _roles;

    // Total akumulasi jumlah Merkle Root yang telah berhasil dijangkarkan ke Ethereum L1
    uint256 public totalAnchoredRoots;

    // Pemetaan pengecekan cepat apakah sebuah Merkle Root spesifik telah terdaftar di kontrak ini
    mapping(bytes32 => bool) public isAnchored;

    // Riwayat daftar indeks Merkle Root: indeks (0, 1, 2, ...) => bytes32 root hash
    mapping(uint256 => bytes32) public batchRoots;

    // Event yang dipancarkan ke jaringan saat Merkle Root baru berhasil dijangkarkan
    event RootAnchored(
        bytes32 indexed root,     // Hash Merkle root batch event Layer 2
        uint64 fromBlock,         // Blok awal Base L2 yang tercakup dalam batch
        uint64 toBlock,           // Blok akhir Base L2 yang tercakup dalam batch
        uint64 timestamp          // Timestamp waktu penyimpanan di Ethereum L1
    );

    // Event pemberian peran baru kepada suatu alamat
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    // Event pencabutan peran dari suatu alamat
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    // --- Definisi Custom Errors ---
    error ACCESS_DENIED();        // Pemanggil tidak memiliki wewenang peran yang dipersyaratkan
    error INVALID_ROOT();         // Hash root kosong (bytes32(0))
    error ALREADY_ANCHORED();     // Hash root sudah pernah dijangkarkan sebelumnya (mencegah duplikasi)

    // Modifier: Memastikan pemanggil adalah pemegang peran tertentu atau Default Admin
    modifier onlyRole(bytes32 role) {
        if (!_roles[role][msg.sender] && !_roles[DEFAULT_ADMIN_ROLE][msg.sender]) {
            revert ACCESS_DENIED();
        }
        _;
    }

    // Konstruktor: Menginisialisasi alamat Admin awal dan alamat akun Anchorer resmi
    constructor(address initialAdmin, address anchorer) {
        // Memberikan peran DEFAULT_ADMIN_ROLE ke alamat initialAdmin
        _roles[DEFAULT_ADMIN_ROLE][initialAdmin] = true;
        // Memberikan peran ANCHORER_ROLE ke alamat anchorer
        _roles[Roles.ANCHORER_ROLE][anchorer] = true;

        // Memancarkan event RoleGranted untuk transparansi on-chain
        emit RoleGranted(DEFAULT_ADMIN_ROLE, initialAdmin, msg.sender);
        emit RoleGranted(Roles.ANCHORER_ROLE, anchorer, msg.sender);
    }

    /// @notice Memeriksa apakah suatu alamat dompet memiliki peran spesifik
    /// @param role Identifier hash dari peran yang diuji
    /// @param account Alamat dompet yang diperiksa
    /// @return bool True jika akun memiliki peran tersebut atau merupakan Admin
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role][account] || _roles[DEFAULT_ADMIN_ROLE][account];
    }

    /// @notice Memberikan wewenang peran kepada akun tertentu (hanya bisa dipanggil oleh Admin)
    function grantRole(bytes32 role, address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _roles[role][account] = true;
        emit RoleGranted(role, account, msg.sender);
    }

    /// @notice Mencabut wewenang peran dari akun tertentu (hanya bisa dipanggil oleh Admin)
    function revokeRole(bytes32 role, address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _roles[role][account] = false;
        emit RoleRevoked(role, account, msg.sender);
    }

    /// @notice Fungsi H-05: Menjangkarkan Merkle root batch baru ke Ethereum L1
    /// @param root Hash Merkle root dari sekumpulan event provenance Base L2
    /// @param fromBlock Nomor blok awal di Base L2
    /// @param toBlock Nomor blok akhir di Base L2
    function anchorRoot(bytes32 root, uint64 fromBlock, uint64 toBlock)
        external
        onlyRole(Roles.ANCHORER_ROLE)
    {
        // 1. Validasi: Root tidak boleh berupa byte kosong 0x0
        if (root == bytes32(0)) revert INVALID_ROOT();

        // 2. Validasi: Pastikan root ini belum pernah dijangkarkan sebelumnya
        if (isAnchored[root]) revert ALREADY_ANCHORED();

        // 3. Simpan status bahwa root ini kini telah sah terjangkar
        isAnchored[root] = true;

        // 4. Masukkan root ke dalam riwayat array batchRoots pada indeks saat ini
        batchRoots[totalAnchoredRoots++] = root;

        // 5. Pancarkan event RootAnchored dengan timestamp block saat ini
        emit RootAnchored(root, fromBlock, toBlock, uint64(block.timestamp));
    }
}
