import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class FeatureHelpData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? accentColor;
  final List<String> howToUse;
  final List<String> benefits;
  final String? securityGuarantee;

  const FeatureHelpData({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.accentColor,
    required this.howToUse,
    required this.benefits,
    this.securityGuarantee,
  });
}

void showFeatureHelp(BuildContext context, FeatureHelpData data) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _FeatureHelpModal(data: data),
  );
}

class FeatureHelpButton extends StatelessWidget {
  final FeatureHelpData helpData;
  final Color? color;
  final double size;

  const FeatureHelpButton({
    super.key,
    required this.helpData,
    this.color,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "How to use & benefits",
      child: InkWell(
        onTap: () => showFeatureHelp(context, helpData),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: (color ?? AppTheme.goldenGateOrange).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: (color ?? AppTheme.goldenGateOrange).withValues(alpha: 0.2),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.help_outline_rounded,
                size: size,
                color: color ?? AppTheme.goldenGateOrange,
              ),
              const SizedBox(width: 4),
              Text(
                "Help",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color ?? AppTheme.goldenGateOrange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureHelpModal extends StatelessWidget {
  final FeatureHelpData data;

  const _FeatureHelpModal({required this.data});

  @override
  Widget build(BuildContext context) {
    final accent = data.accentColor ?? AppTheme.goldenGateOrange;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // macOS Handle & Window Traffic Light styling
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // macOS traffic lights subtle hint
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Icon(data.icon, color: accent, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              data.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Guide & Benefits",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content body
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // How to Use Section
                  _buildSectionHeader(
                    icon: Icons.checklist_rounded,
                    title: "How to Use This Feature",
                    color: AppTheme.pacificNavy,
                  ),
                  const SizedBox(height: 12),
                  ...data.howToUse.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final text = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              "$index",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: accent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              text,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: AppTheme.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // Benefits Section
                  _buildSectionHeader(
                    icon: Icons.shield_outlined,
                    title: "Key Advantages & Value",
                    color: AppTheme.sunsetAmber,
                  ),
                  const SizedBox(height: 12),
                  ...data.benefits.map((benefit) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.bgLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: AppTheme.successGreen,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              benefit,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  if (data.securityGuarantee != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lock_rounded, size: 16, color: Color(0xFFB45309)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Cryptographic Security Guarantee",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFB45309),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  data.securityGuarantee!,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    color: const Color(0xFF92400E),
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Got it action
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        "Got It",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

