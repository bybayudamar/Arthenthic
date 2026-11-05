import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../shared/artistic_background.dart';
import '../shared/feature_help_dialog.dart';

class GallerySafeConsole extends StatefulWidget {
  const GallerySafeConsole({super.key});

  @override
  State<GallerySafeConsole> createState() => _GallerySafeConsoleState();
}

class _GallerySafeConsoleState extends State<GallerySafeConsole> {
  int _selectedTab = 0; // 0: Intake Queue, 1: Safe Mint (B-08), 2: Treasury Vault, 3: Batch Verifier
  bool _isSigningTx = false;
  String? _statusBanner;

  static const FeatureHelpData _gallerySafeHelp = FeatureHelpData(
    title: "Gallery Safe & Verifier Console",
    subtitle: "Institutional Gnosis Safe multisig & physical artwork intake",
    icon: Icons.account_balance_rounded,
    howToUse: [
      "Navigate between Intake Queue, Safe Mint, Treasury, and Batch Verifier using the top pills.",
      "In 'Intake Queue', inspect incoming artist submissions and verify LiDAR biometric match (>88%).",
      "In 'Safe Mint Queue (B-08)', review pending multi-sig mint orders and execute with Gnosis Safe 2-of-3 signatures.",
      "Use 'Batch Verifier' during physical gallery exhibition check-ins to rapidly tap and verify multiple canvases.",
    ],
    benefits: [
      "Institutional Multi-Sig Security: Requires 2-of-3 gallery directors to sign minting transactions.",
      "Gasless Sponsorship: Transactions are sponsored through the Arthentic ERC-4337 Paymaster.",
      "Tamper-Proof Consignment: Every physical intake is cryptographically bound to Base L2 smart contracts.",
    ],
    securityGuarantee: "SC-CHIP-01 chip collision rejection prevents reusing an NFC UID on another artwork.",
  );

  final List<Map<String, dynamic>> _intakeDossiers = [
    {
      "id": "DOS-2024-001",
      "title": "Pacific Coastal Twilight",
      "artist": "Elena Rostova",
      "medium": "Oil & Impasto on Linen (120 × 90 cm)",
      "similarity": 98.4,
      "tagUid": "04A1B2C3D4E580",
      "status": "Ready for Approval",
      "image": "assets/images/canvas_sample_1.jpg",
    },
    {
      "id": "DOS-2024-002",
      "title": "Abstract Geometric Relief III",
      "artist": "Kaito Tanaka",
      "medium": "Encaustic & Mixed Media on Board (80 × 80 cm)",
      "similarity": 96.8,
      "tagUid": "04B2C3D4E5F681",
      "status": "Review Required",
      "image": "assets/images/canvas_sample_2.jpg",
    },
    {
      "id": "DOS-2024-003",
      "title": "Sonoma Vineyards After Rain",
      "artist": "Sarah Jenkins",
      "medium": "Oil on Canvas (100 × 75 cm)",
      "similarity": 99.1,
      "tagUid": "04C3D4E5F6A782",
      "status": "Ready for Approval",
      "image": "assets/images/canvas_sample_3.jpg",
    },
  ];

  final List<Map<String, dynamic>> _mintQueue = [
    {
      "txId": "SAFE-TX-109",
      "title": "Sunset Over Pacific Horizon",
      "tokenId": "101",
      "signatures": "1 of 2 Signed",
      "required": 2,
      "paymaster": "Sponsored (0 ETH gas)",
      "gasEstimate": "0.00042 ETH",
      "ready": true,
    },
    {
      "txId": "SAFE-TX-110",
      "title": "Golden Gate Fog & Coastal Ridge",
      "tokenId": "102",
      "signatures": "2 of 2 Signed",
      "required": 2,
      "paymaster": "Sponsored (0 ETH gas)",
      "gasEstimate": "0.00038 ETH",
      "ready": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: ArtisticBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mobile-Friendly Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.goldenGateOrange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppTheme.goldenGateOrange.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Icon(
                            Icons.account_balance_rounded,
                            color: AppTheme.goldenGateOrange,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Gallery Safe Vault",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.successGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "Gnosis Safe 2-of-3 · Base L2",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const FeatureHelpButton(helpData: _gallerySafeHelp),
                  ],
                ),
              ),

              // Segmented Navigation Bar (Horizontal Scrollable for Mobile)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildPill(0, "Intake Queue (3)", Icons.inbox_rounded),
                      _buildPill(1, "Safe Mint B-08 (2)", Icons.fingerprint_rounded),
                      _buildPill(2, "Treasury (\$1.48M)", Icons.account_balance_wallet_rounded),
                      _buildPill(3, "Batch Tap Verifier", Icons.checklist_rounded),
                    ],
                  ),
                ),
              ),

              if (_statusBanner != null) ...[
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _statusBanner!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.successGreen,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _statusBanner = null),
                        child: const Icon(Icons.close, size: 14, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // Active Tab Content View
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Column(
                    children: [
                      if (_selectedTab == 0) _buildIntakeQueueTab(),
                      if (_selectedTab == 1) _buildSafeMintTab(),
                      if (_selectedTab == 2) _buildTreasuryTab(),
                      if (_selectedTab == 3) _buildBatchVerifierTab(),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPill(int index, String title, IconData icon) {
    final isSelected = _selectedTab == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.goldenGateOrange.withValues(alpha: 0.15)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.goldenGateOrange : AppTheme.borderLight,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? AppTheme.goldenGateOrange : AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? AppTheme.goldenGateOrange : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntakeQueueTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Artist Intake Dossiers",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.infoBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "VERIFIER_ROLE",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.infoBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ..._intakeDossiers.map((d) {
          final isHighMatch = (d["similarity"] as double) >= 98.0;
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.borderLight),
              boxShadow: AppTheme.macCardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 64,
                        height: 64,
                        color: AppTheme.bgLight,
                        child: Image.asset(
                          d["image"],
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.brush_rounded,
                            color: AppTheme.goldenGateOrange,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                d["id"],
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isHighMatch
                                      ? AppTheme.successGreen.withValues(alpha: 0.1)
                                      : AppTheme.warningOrange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "${d["similarity"]}% Match",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: isHighMatch
                                        ? AppTheme.successGreen
                                        : AppTheme.warningOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            d["title"],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            d["artist"],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppTheme.goldenGateOrange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            d["medium"],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.bgLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.nfc_rounded, size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        "NXP DNA UID: ${d["tagUid"]}",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _statusBanner = "Dossier ${d["id"]} sent back for recalibration";
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Request Delta",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _statusBanner = "Dossier ${d["id"]} verified! Queued for Safe Mint (B-08)";
                            _intakeDossiers.remove(d);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.goldenGateOrange,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Approve Intake",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSafeMintTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Gnosis Safe 2-of-3 Mint Queue",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "ERC-4337 Sponsored",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.successGreen,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ..._mintQueue.map((tx) {
          final isReady = tx["ready"] as bool;
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.borderLight),
              boxShadow: AppTheme.macCardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tx["txId"],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.goldenGateOrange,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isReady
                            ? AppTheme.warningOrange.withValues(alpha: 0.1)
                            : AppTheme.successGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tx["signatures"],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: isReady ? AppTheme.warningOrange : AppTheme.successGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  tx["title"],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  "Token ID #${tx["tokenId"]} · Base L2 Genesis Mint",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.bgLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.flash_on_rounded, size: 14, color: AppTheme.champagneGold),
                          const SizedBox(width: 4),
                          Text(
                            tx["paymaster"],
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Text(
                        tx["gasEstimate"],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSigningTx
                        ? null
                        : () async {
                            setState(() => _isSigningTx = true);
                            await Future.delayed(const Duration(milliseconds: 1200));
                            if (mounted) {
                              setState(() {
                                _isSigningTx = false;
                                _statusBanner = "Safe Tx ${tx["txId"]} signed & broadcast to Base L2!";
                                _mintQueue.remove(tx);
                              });
                            }
                          },
                    icon: _isSigningTx
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.fingerprint_rounded, size: 16),
                    label: Text(
                      _isSigningTx ? "Signing with Safe..." : "Sign 2nd Signature & Execute",
                      style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.goldenGateOrange,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTreasuryTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.pacificNavy, Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: AppTheme.macCardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "TOTAL CONSIGNED VALUATION",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "\$1,480,000 USD",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildTreasuryBadge("14 Physical Canvases", Icons.palette_outlined),
                  const SizedBox(width: 10),
                  _buildTreasuryBadge("Lloyd's Insured Vault", Icons.verified_user_outlined),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        Text(
          "Vault Assets Under Custody",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 10),

        _buildVaultItem("Sunset Over Pacific Horizon", "Elena Rostova", "\$380,000", "04A1B2C3D4E580"),
        _buildVaultItem("Golden Gate Fog & Coastal Ridge", "Marcus Vance", "\$520,000", "04B2C3D4E5F681"),
        _buildVaultItem("Chromatic Canvas Study No. 4", "Clara Beauchamp", "\$240,000", "04C3D4E5F6A782"),
        _buildVaultItem("Monochrome Impasto Elevation", "David Chen", "\$340,000", "04D4E5F6A7B883"),
      ],
    );
  }

  Widget _buildTreasuryBadge(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaultItem(String title, String artist, String val, String uid) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.bgLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shield_outlined, size: 18, color: AppTheme.goldenGateOrange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                Text(
                  "$artist · UID $uid",
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            val,
            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchVerifierTab() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.macCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Batch Exhibition NFC Check-In",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Rapidly tap canvases on gallery intake or before public opening to ensure zero physical substitutions.",
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: AppTheme.bgLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.goldenGateOrange.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.goldenGateOrange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.nfc_rounded, size: 36, color: AppTheme.goldenGateOrange),
                ),
                const SizedBox(height: 12),
                Text(
                  "Ready to Scan Physical Artwork",
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                Text(
                  "Hold iPhone near bottom stretcher frame tag",
                  style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _statusBanner = "Tag 04A1B2C3D4E580 verified! Tamper loop INTACT (Counter: 15)";
                });
              },
              icon: const Icon(Icons.wifi_tethering_rounded, size: 16),
              label: Text(
                "Trigger Simulated NFC Tap Check",
                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.goldenGateOrange,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
