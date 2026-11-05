import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/models.dart';
import '../../services/api_client.dart';
import '../shared/artistic_background.dart';
import '../shared/feature_help_dialog.dart';
import '../genesis/coa_screen.dart';

class ArtworkMeta {
  final String tokenId;
  final String title;
  final String artist;
  final String year;
  final String medium;
  final String currentCustodian;
  final String imagePath;
  final double similarity;
  final String blockHeight;

  const ArtworkMeta({
    required this.tokenId,
    required this.title,
    required this.artist,
    required this.year,
    required this.medium,
    required this.currentCustodian,
    required this.imagePath,
    required this.similarity,
    required this.blockHeight,
  });
}

class ProvenanceScreen extends StatefulWidget {
  final String tokenId;

  const ProvenanceScreen({super.key, this.tokenId = "101"});

  @override
  State<ProvenanceScreen> createState() => _ProvenanceScreenState();
}

class _ProvenanceScreenState extends State<ProvenanceScreen> {
  late String _selectedTokenId;
  int _activeViewTab = 0; // 0: Timeline, 1: Biometric Delta, 2: Cryptographic Proofs
  List<ProvenanceEvent> _events = [];
  bool _isLoading = true;

  final Map<String, ArtworkMeta> _artworks = const {
    "101": ArtworkMeta(
      tokenId: "101",
      title: "Sunset Over Pacific Horizon",
      artist: "Elena Rostova",
      year: "2024",
      medium: "Oil & Impasto on Linen Canvas (120 × 90 cm)",
      currentCustodian: "Gnosis Safe 0x82A1...9F02 (Gallery Vault)",
      imagePath: "assets/images/canvas_sample_1.jpg",
      similarity: 98.4,
      blockHeight: "24,918,204",
    ),
    "102": ArtworkMeta(
      tokenId: "102",
      title: "Golden Gate Fog & Coastal Ridge",
      artist: "Marcus Vance",
      year: "2023",
      medium: "Textured Acrylic & Marble Dust (150 × 100 cm)",
      currentCustodian: "Private Collector 0x43b2...11ce",
      imagePath: "assets/images/canvas_sample_2.jpg",
      similarity: 99.1,
      blockHeight: "23,104,892",
    ),
    "103": ArtworkMeta(
      tokenId: "103",
      title: "Chromatic Canvas Study No. 4",
      artist: "Clara Beauchamp",
      year: "2024",
      medium: "Encaustic Wax & Oil Impasto on Wood Panel",
      currentCustodian: "Arthentic Escrow Vault 0x1111...0002",
      imagePath: "assets/images/canvas_sample_3.jpg",
      similarity: 97.8,
      blockHeight: "25,002,110",
    ),
  };

  static const FeatureHelpData _provenanceHelp = FeatureHelpData(
    title: "Provenance & Custody Timeline",
    subtitle: "Immutable cryptographic history anchored to Base L2 & Ethereum L1",
    icon: Icons.history_edu_rounded,
    howToUse: [
      "Select an artwork token above (#101, #102, #103) to inspect its full provenance history.",
      "Switch between 'Custody Timeline', 'Biometric Delta', and 'On-Chain Proofs' via the view pills.",
      "Tap any event card to view the exact Base L2 transaction hash, EIP-712 signer address, and timestamp.",
      "Tap 'View Certificate of Authenticity (CoA)' to inspect the public decentralized CoA record.",
    ],
    benefits: [
      "SC-GEN-01 Guarantee: Optical and LiDAR fingerprint is committed permanently at genesis and can never be altered.",
      "Zero counterfeit risk: Every physical transfer requires dual-layer (LiDAR + NFC) re-verification.",
      "Collector resale protection: Clean, unbroken chain of verified ownership maximizes fine art valuation.",
    ],
    securityGuarantee: "Every state transition is signed by Protocol Node HSM/KMS signers and recorded on Base L2 block receipts.",
  );

  @override
  void initState() {
    super.initState();
    _selectedTokenId = widget.tokenId;
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    final events = await apiClient.getProvenance(_selectedTokenId);
    if (mounted) {
      setState(() {
        _events = events;
        _isLoading = false;
      });
    }
  }

  void _switchArtwork(String tokenId) {
    if (_selectedTokenId == tokenId) return;
    setState(() {
      _selectedTokenId = tokenId;
    });
    _loadEvents();
  }

  ArtworkMeta get _currentMeta =>
      _artworks[_selectedTokenId] ??
      ArtworkMeta(
        tokenId: _selectedTokenId,
        title: "Fine Artwork #$_selectedTokenId",
        artist: "Verified Artist",
        year: "2024",
        medium: "Oil on Linen Canvas",
        currentCustodian: "Arthentic Safe Vault",
        imagePath: "assets/images/canvas_sample_1.jpg",
        similarity: 98.0,
        blockHeight: "24,900,000",
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: ArtisticBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with Help Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Provenance",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          "Immutable on-chain verification chain",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const FeatureHelpButton(helpData: _provenanceHelp),
                  ],
                ),
              ),

              // Token Selector Pills
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _artworks.keys.map((tId) {
                      final isSelected = _selectedTokenId == tId;
                      final meta = _artworks[tId]!;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text("Token #$tId · ${meta.artist.split(' ').first}"),
                          selected: isSelected,
                          onSelected: (_) => _switchArtwork(tId),
                          selectedColor: AppTheme.goldenGateOrange.withValues(alpha: 0.15),
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.goldenGateOrange
                                : AppTheme.borderLight,
                          ),
                          labelStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? AppTheme.goldenGateOrange
                                : AppTheme.textPrimary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Scrollable Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.goldenGateOrange,
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildArtworkHeroCard(_currentMeta),
                            const SizedBox(height: 18),
                            _buildViewModePills(),
                            const SizedBox(height: 18),
                            if (_activeViewTab == 0) _buildTimelineView(),
                            if (_activeViewTab == 1) _buildBiometricDeltaView(),
                            if (_activeViewTab == 2) _buildCryptographicProofsView(),
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

  Widget _buildArtworkHeroCard(ArtworkMeta meta) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.macCardShadow,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 80,
                  height: 80,
                  color: AppTheme.bgLight,
                  child: Image.asset(
                    meta.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.palette_rounded,
                      color: AppTheme.goldenGateOrange,
                      size: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Meta info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.successGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified_rounded, size: 12, color: AppTheme.successGreen),
                              const SizedBox(width: 4),
                              Text(
                                "SC-GEN-01 IMMUTABLE",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.successGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meta.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      "${meta.artist} (${meta.year})",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.goldenGateOrange,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meta.medium,
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
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Quick statistics strip
          Row(
            children: [
              _buildStatCol("Biometric Match", "${meta.similarity}%", Icons.fingerprint_rounded, AppTheme.successGreen),
              _buildStatCol("Tamper Loop", "INTACT", Icons.shield_rounded, AppTheme.infoBlue),
              _buildStatCol("Base L2 Block", "#${meta.blockHeight}", Icons.link_rounded, AppTheme.sunsetAmber),
            ],
          ),
          const SizedBox(height: 14),

          // CoA Shortcut Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CertificateOfAuthenticityScreen(tokenId: meta.tokenId),
                  ),
                );
              },
              icon: const Icon(Icons.document_scanner_outlined, size: 16),
              label: Text(
                "Inspect Full Certificate of Authenticity (CoA)",
                style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.goldenGateOrange, width: 1.2),
                foregroundColor: AppTheme.goldenGateOrange,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCol(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModePills() {
    final tabs = ["Custody Timeline", "LiDAR Biometric Delta", "On-Chain Proofs"];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.bgSubtle,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: tabs.asMap().entries.map((e) {
          final isSelected = _activeViewTab == e.key;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeViewTab = e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  e.value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppTheme.goldenGateOrange : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimelineView() {
    final displayEvents = _events.isNotEmpty
        ? _events
        : [
            ProvenanceEvent(
              type: "GENESIS_ENROLLMENT",
              role: "Artist",
              actor: "0x82a1...9f02",
              timestamp: "2024-04-12 10:30 UTC",
              details: "Optical weave & LiDAR 3D mesh hash committed on Base L2",
            ),
            ProvenanceEvent(
              type: "GALLERY_CONSIGNMENT",
              role: "Gallery Vault",
              actor: "0x3b12...5f21",
              timestamp: "2024-06-01 14:15 UTC",
              details: "Physical intake verified with Gnosis Safe 2-of-3",
            ),
            ProvenanceEvent(
              type: "CONSERVATOR_CONDITION_AUDIT",
              role: "Conservator Lab",
              actor: "0x2034...9012",
              timestamp: "2024-09-18 16:40 UTC",
              details: "Impasto relief audited; 99.2% craquelure stability sealed on Arweave",
            ),
            ProvenanceEvent(
              type: "ESCROW_CUSTODY_HANDOFF",
              role: "Collector Escrow",
              actor: "0x44fa...01a2",
              timestamp: "2024-11-04 09:12 UTC",
              details: "Buyer iPhone LiDAR delivery confirmation; escrow funds released",
            ),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Chronological Event Graph (${displayEvents.length} events)",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              "Base L2 Verified",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.successGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayEvents.length,
          itemBuilder: (context, index) {
            final ev = displayEvents[index];
            final isGenesis = ev.type == "GENESIS_ENROLLMENT";
            final isLast = index == displayEvents.length - 1;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline Node & Vertical Connector Line
                  Column(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isGenesis
                              ? AppTheme.goldenGateOrange
                              : AppTheme.sunsetAmber,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: (isGenesis
                                      ? AppTheme.goldenGateOrange
                                      : AppTheme.sunsetAmber)
                                  .withValues(alpha: 0.3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Icon(
                          isGenesis ? Icons.brush_rounded : Icons.verified_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: const Color(0xFFCBD5E1),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),

                  // Event Card
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: (isGenesis
                                          ? AppTheme.goldenGateOrange
                                          : AppTheme.sunsetAmber)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  ev.type.replaceAll("_", " "),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: isGenesis
                                        ? AppTheme.goldenGateOrange
                                        : AppTheme.sunsetAmber,
                                  ),
                                ),
                              ),
                              Text(
                                ev.timestamp,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${ev.role} · ${ev.actor}",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ev.details,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.bgLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.link_rounded, size: 12, color: AppTheme.infoBlue),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "Actor: ${ev.actor}",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      fontFeatures: const [FontFeature.tabularFigures()],
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.open_in_new_rounded, size: 11, color: AppTheme.textMuted),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBiometricDeltaView() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Physical Biometric Comparison",
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
                  "98.4% MATCH",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.successGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Compares current iPhone LiDAR mesh point clouds against genesis master scan.",
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 18),

          // Visual Simulation of Surface Delta
          Container(
            height: 140,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.bgLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.view_in_ar_rounded, size: 36, color: AppTheme.goldenGateOrange),
                      const SizedBox(height: 6),
                      Text("Genesis Scan", style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700)),
                      Text("480k Points", style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.compare_arrows_rounded, color: AppTheme.successGreen, size: 18),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.document_scanner_rounded, size: 36, color: AppTheme.infoBlue),
                      const SizedBox(height: 6),
                      Text("Latest Field Scan", style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700)),
                      Text("480k Points", style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Verification checklist
          _buildCheckRow("Impasto Craquelure Consistency", "99.2%", "Zero unrecorded degradation"),
          _buildCheckRow("Optical Canvas Weave Alignment", "98.1%", "320Hz frequency match verified"),
          _buildCheckRow("Flat Paper Print Spoof Gate", "PASSED", "Surface non-flatness confirmed (depth var > 0.8mm)"),
          _buildCheckRow("NXP SUN CMAC Key Verification", "VALID", "Dynamic CMAC counter = 14"),
        ],
      ),
    );
  }

  Widget _buildCheckRow(String title, String val, String sub) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, size: 16, color: AppTheme.successGreen),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700)),
                    Text(val, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.successGreen)),
                  ],
                ),
                Text(sub, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptographicProofsView() {
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
            "Cryptographic Attestations (EIP-712)",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Cryptographically signed by HSM/KMS Protocol Signer and settled on EVM Base L2.",
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),

          _buildProofField("EIP-712 Structured Digest", "0x9812f8a49c0d12e847c9bb101e42817293a812bc678a1042c12"),
          _buildProofField("Protocol Node Signer (HSM)", "0x203490AbCe88172901Bf990184AcE8271B890212"),
          _buildProofField("Base L2 Contract (ArthenticNFT)", "0x1111111111111111111111111111111111110001"),
          _buildProofField("Arweave Permanent Storage CID", "ar://Vq98_NMcZ0293kd81792Lka812049182310b82"),
          _buildProofField("Ethereum L1 Merkle Anchor Root", "0x89fa014298ccbb2198001248012bbcc481239011289"),
        ],
      ),
    );
  }

  Widget _buildProofField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.bgLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.copy_rounded, size: 14, color: AppTheme.textMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
