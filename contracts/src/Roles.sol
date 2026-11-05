// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Roles Library
/// @notice Mendefinisikan konstanta hash keccak256 untuk sistem Access Control berbasis peran (RBAC)
/// di seluruh ekosistem smart contract Arthentic (Base L2 & Ethereum L1).
library Roles {
    // Peran Seniman: Berhak menandatangani (co-sign) genesis mint dan menerima royalti penjualan ERC-2981.
    bytes32 internal constant ARTIST_ROLE        = keccak256("ARTIST_ROLE");

    // Peran Galeri / Verifier Terakreditasi: Berhak memanggil genesisMint, co-signing safe minting, dan replaceChip.
    bytes32 internal constant VERIFIER_ROLE      = keccak256("VERIFIER_ROLE");

    // Peran Konservator / Restorer: Berhak mengunggah condition report dan memperbarui vektor kondisi fisik (updateCondition).
    bytes32 internal constant CONSERVATOR_ROLE   = keccak256("CONSERVATOR_ROLE");

    // Peran Protocol Node (HSM/KMS): Berhak menerbitkan dan menandatangani EIP-712 Attestation setelah validasi SUN CMAC & LiDAR.
    bytes32 internal constant PROTOCOL_NODE_ROLE = keccak256("PROTOCOL_NODE_ROLE");

    // Peran Anchorer: Berhak mengomit Merkle Root batch event provenance Base L2 ke kontrak MerkleAnchor di Ethereum L1.
    bytes32 internal constant ANCHORER_ROLE      = keccak256("ANCHORER_ROLE");
}
