import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../shared/artistic_background.dart';
import '../shared/feature_help_dialog.dart';
import '../conservation/restoration_screen.dart';

class ConservatorStudioConsole extends StatefulWidget {
  const ConservatorStudioConsole({super.key});

  @override
  State<ConservatorStudioConsole> createState() => _ConservatorStudioConsoleState();
}

class _ConservatorStudioConsoleState extends State<ConservatorStudioConsole> {
  int _selectedTab = 0; // 0: Cases, 1: Dossier Builder (E-04), 2: 3-of-3 Chip Swap (F-05), 3: Arweave Archive
  final TextEditingController _notesController = TextEditingController(
    text: "Micro-cleaning completed on lower left impasto quadrant. Stabilized craquelure with museum-grade reversable B-72 resin. Zero optical weave distortion detected.",
  );
  double _craquelureIndex = 14.0;
  double _varnishDegradation = 8.0;
  bool _isUploadingToArweave = false;
  String? _statusBanner;

  static const FeatureHelpData _conservatorHelp = FeatureHelpData(
    title: "Conservator Studio & Arweave Archive",
    subtitle: "Permanent condition dossiers & 3-of-3 chip replacement governance",
    icon: Icons.biotech_rounded,
    howToUse: [
      "Review active conservation orders and owner consent statuses in 'Restoration Cases (E-01)'.",
      "Record physical condition metrics (craquelure, varnish, canvas tension) in 'Treatment Dossier (E-04)'.",
      "Tap 'Commit Dossier to Arweave' to permanently seal the treatment record onto the decentralized permaweb.",
      "If an NFC chip is physically damaged, initiate '3-of-3 Chip Replacement (F-05)' requiring Conservator + Gallery + Owner signatures.",
    ],
    benefits: [
      "Permanent Arweave Permaweb Storage: Treatment records and high-res imagery can never be altered or lost.",
      "F-05 Multi-Party Governance: No single entity can replace an artwork's NFC tag without 3-of-3 authorization.",
      "Owner Consent Gate (E-07*): Requires verified collector signature before any invasive restoration work.",
    ],
    securityGuarantee: "SC-GEN-01 genesis hash immutability ensures physical canvas biometric cannot be spoofed.",
  );

  final List<Map<String, dynamic>> _activeCases = [
    {
      "caseId": "CNS-2024-88",
      "title": "Sunset Over Pacific Horizon",
      "artist": "Elena Rostova",
      "tokenId": "101",
      "status": "In Treatment (Phase 2)",
      "consentStatus": "Owner Consent Verified (E-07*)",
      "conditionScore": "94.2% Good",
      "image": "assets/images/canvas_sample_1.jpg",
    },
    {
      "caseId": "CNS-2024-91",
      "title": "Chromatic Canvas Study No. 4",
      "artist": "Clara Beauchamp",
      "tokenId": "103",
      "status": "Awaiting Inspection",
      "consentStatus": "Consent Signature Pending",
      "conditionScore": "97.8% Excellent",
      "image": "assets/images/canvas_sample_3.jpg",
    },
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

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
                            color: const Color(0xFFDB2777).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFDB2777).withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Icon(
                            Icons.biotech_rounded,
                            color: Color(0xFFDB2777),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Conservator Studio",
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
                                  "CONSERVATOR_ROLE · Certified",
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
                    const FeatureHelpButton(helpData: _conservatorHelp),
                  ],
                ),
              ),

              // Segmented Tabs Pill Selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildPill(0, "Active Cases (2)", Icons.assignment_outlined),
                      _buildPill(1, "Dossier Builder (E-04)", Icons.edit_note_rounded),
                      _buildPill(2, "3-of-3 Chip Swap (F-05)", Icons.sync_alt_rounded),
                      _buildPill(3, "Arweave Archive", Icons.cloud_done_outlined),
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
                      if (_selectedTab == 0) _buildCasesTab(),
                      if (_selectedTab == 1) _buildDossierBuilderTab(),
                      if (_selectedTab == 2) _buildChipSwapTab(),
                      if (_selectedTab == 3) _buildArweaveArchiveTab(),
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
                ? const Color(0xFFDB2777).withValues(alpha: 0.12)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFFDB2777) : AppTheme.borderLight,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? const Color(0xFFDB2777) : AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? const Color(0xFFDB2777) : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCasesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Active Conservation Treatments",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.goldenGateOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "E-07* Gated",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.goldenGateOrange,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ..._activeCases.map((c) {
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
                          c["image"],
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.brush_rounded,
                            color: Color(0xFFDB2777),
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
                                c["caseId"],
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.infoBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  c["conditionScore"],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.infoBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            c["title"],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            "${c["artist"]} · Token #${c["tokenId"]}",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFFDB2777),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.bgLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user_rounded, size: 14, color: AppTheme.successGreen),
                      const SizedBox(width: 6),
                      Text(
                        c["consentStatus"],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RestorationScreen(tokenId: c["tokenId"]),
                        ),
                      );
                    },
                    icon: const Icon(Icons.open_in_new_rounded, size: 14),
                    label: Text(
                      "Open Dedicated Restoration Studio",
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDB2777),
                      side: const BorderSide(color: Color(0xFFDB2777)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  Widget _buildDossierBuilderTab() {
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
                "Treatment Dossier Builder (E-04)",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDB2777).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Arweave Linked",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFDB2777),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Document micro-structural treatment and anchor permanent condition report.",
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),

          // Slider 1: Craquelure Severity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Craquelure Severity Index",
                style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
              Text(
                "${_craquelureIndex.toInt()}% (Stable)",
                style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.successGreen),
              ),
            ],
          ),
          Slider(
            value: _craquelureIndex,
            min: 0,
            max: 100,
            activeColor: const Color(0xFFDB2777),
            onChanged: (val) => setState(() => _craquelureIndex = val),
          ),

          // Slider 2: Varnish Degradation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Surface Varnish Yellowing / Wear",
                style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
              Text(
                "${_varnishDegradation.toInt()}% (Minimal)",
                style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.infoBlue),
              ),
            ],
          ),
          Slider(
            value: _varnishDegradation,
            min: 0,
            max: 100,
            activeColor: AppTheme.infoBlue,
            onChanged: (val) => setState(() => _varnishDegradation = val),
          ),

          const SizedBox(height: 8),
          Text(
            "Conservation Log & Chemical Treatment Notes",
            style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _notesController,
            maxLines: 4,
            style: GoogleFonts.plusJakartaSans(fontSize: 12.5),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.bgLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.borderLight),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isUploadingToArweave
                  ? null
                  : () async {
                      setState(() => _isUploadingToArweave = true);
                      await Future.delayed(const Duration(milliseconds: 1400));
                      if (mounted) {
                        setState(() {
                          _isUploadingToArweave = false;
                          _statusBanner = "Treatment dossier committed to Arweave (CID: ar://k982_NMc293...)";
                        });
                      }
                    },
              icon: _isUploadingToArweave
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.cloud_upload_rounded, size: 16),
              label: Text(
                _isUploadingToArweave ? "Encrypting & Sealing..." : "Commit Dossier to Arweave Permaweb",
                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDB2777),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipSwapTab() {
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
                "3-of-3 Chip Replacement (F-05)",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.warningOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Multi-Party Gate",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.warningOrange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Hardware NXP NFC chip replacement on damaged stretcher frame requires 3-of-3 cryptographic quorum.",
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 18),

          _buildStepRow(1, "Accredited Conservator", "Signed with HSM key (0x2034...9012)", true),
          _buildStepRow(2, "Gallery Custodian", "Signed with Gnosis Safe (0x82A1...9F02)", true),
          _buildStepRow(3, "Artwork Owner (Collector)", "Awaiting EIP-712 Signature via Wallet", false),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.security_rounded, size: 16, color: Color(0xFFB45309)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Circuit Breaker Active: Old chip UID is frozen on Base L2 contract. Replacement tag will only activate when 3rd signature settles.",
                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF92400E)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(int step, String role, String status, bool isComplete) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isComplete ? AppTheme.successGreen : const Color(0xFFCBD5E1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isComplete ? Icons.check : Icons.lock_outline_rounded,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
                Text(
                  status,
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArweaveArchiveTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Permanent Arweave Records",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 10),

        _buildArchiveItem("Dossier #AR-101-2024", "Sunset Over Pacific Horizon", "ar://vQ98_nmC20918Lka", "Nov 2, 2024"),
        _buildArchiveItem("Dossier #AR-102-2023", "Golden Gate Fog & Coastal Ridge", "ar://mB12_kd88901239c", "Aug 14, 2023"),
        _buildArchiveItem("Genesis Audit #AR-103", "Chromatic Canvas Study No. 4", "ar://pL01_aa99018247f", "Jan 19, 2024"),
      ],
    );
  }

  Widget _buildArchiveItem(String id, String artwork, String cid, String date) {
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
              color: const Color(0xFFDB2777).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.cloud_done_rounded, size: 18, color: Color(0xFFDB2777)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artwork,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                Text(
                  "$id · $cid",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            date,
            style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
