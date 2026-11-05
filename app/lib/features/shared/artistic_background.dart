import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// macOS Golden Gate Ambient Background
/// Subtle warm ambient gradients inspired by San Francisco Bay sunrise,
/// International Orange glow, warm champagne mist, and clean Apple frosted surfaces.
class ArtisticBackground extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const ArtisticBackground({
    super.key,
    required this.child,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base subtle background
        Container(
          color: isDark ? const Color(0xFF0F172A) : AppTheme.bgLight,
        ),

        // Golden Gate International Orange Ambient Glow (Top Right)
        Positioned(
          top: -120,
          right: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [
                        AppTheme.goldenGateOrange.withValues(alpha: 0.15),
                        Colors.transparent,
                      ]
                    : [
                        AppTheme.goldenGateOrange.withValues(alpha: 0.08),
                        AppTheme.champagneGold.withValues(alpha: 0.04),
                        Colors.transparent,
                      ],
              ),
            ),
          ),
        ),

        // Warm Champagne Sunlit Mist (Bottom Left)
        Positioned(
          bottom: -100,
          left: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [
                        AppTheme.sunsetAmber.withValues(alpha: 0.1),
                        Colors.transparent,
                      ]
                    : [
                        AppTheme.sunsetAmber.withValues(alpha: 0.06),
                        AppTheme.champagneGold.withValues(alpha: 0.03),
                        Colors.transparent,
                      ],
              ),
            ),
          ),
        ),

        // Pacific Slate subtle breeze (Center)
        Positioned(
          top: 250,
          right: 30,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.infoBlue.withValues(alpha: 0.03),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Foreground Content
        child,
      ],
    );
  }
}
