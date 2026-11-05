import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import 'gallery_safe_console.dart';
import 'conservator_console.dart';
import 'admin_incident_console.dart';

/// Institutional Consoles Hub
/// Combines the 3 institutional back-office workspaces into a unified,
/// sleek, mobile-optimized console screen with a polished segmented switcher:
/// - 0: Gallery Safe (Multisig Treasury, Safe Minting B-08, Intake Queue)
/// - 1: Conservator Studio (Restoration Dossiers, Microscopic Diff, 3-of-3 Chip Replacement)
/// - 2: Protocol Governance (Admin Incident Console, SLA KPIs, Circuit Breaker)
class ConsolesHubScreen extends StatefulWidget {
  final int initialConsoleIndex;
  final ValueChanged<int>? onConsoleChanged;

  const ConsolesHubScreen({
    super.key,
    this.initialConsoleIndex = 0,
    this.onConsoleChanged,
  });

  @override
  State<ConsolesHubScreen> createState() => _ConsolesHubScreenState();
}

class _ConsolesHubScreenState extends State<ConsolesHubScreen> {
  late int _activeConsole;

  @override
  void initState() {
    super.initState();
    _activeConsole = widget.initialConsoleIndex.clamp(0, 2);
  }

  void _selectConsole(int index) {
    setState(() => _activeConsole = index);
    widget.onConsoleChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Institutional Segmented Control Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF385C).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.hub_rounded,
                          size: 18,
                          color: Color(0xFFFF385C),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Institutional Consoles",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Restricted Role",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Segmented Switcher Pills
                  Container(
                    height: 42,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        _buildSegmentButton(
                          index: 0,
                          icon: Icons.account_balance_rounded,
                          label: "Gallery Safe",
                        ),
                        _buildSegmentButton(
                          index: 1,
                          icon: Icons.biotech_rounded,
                          label: "Conservator",
                        ),
                        _buildSegmentButton(
                          index: 2,
                          icon: Icons.shield_rounded,
                          label: "Governance",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Active Console View
            Expanded(
              child: IndexedStack(
                index: _activeConsole,
                children: const [
                  GallerySafeConsole(),
                  ConservatorStudioConsole(),
                  AdminIncidentConsole(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentButton({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _activeConsole == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectConsole(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(19),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? const Color(0xFFFF385C) : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? const Color(0xFFFF385C) : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

