import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../main.dart';
import '../../services/app_lock_service.dart';
import '../shared/artistic_background.dart';
import '../shared/feature_help_dialog.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const FeatureHelpData _welcomeHelp = FeatureHelpData(
    title: "Arthentic Protocol Onboarding",
    subtitle: "Getting started with physical artwork authentication",
    icon: Icons.fingerprint_rounded,
    howToUse: [
      "Select 'Sign In' to log into your accredited collector, gallery, or artist profile.",
      "Choose 'Continue as Guest' to immediately test public NFC tap verification and browse provenance.",
      "New gallery or certified conservator? Tap 'Apply for Accreditation' to submit credentials.",
    ],
    benefits: [
      "Zero registration required for zero-install visitor verification.",
      "Hardware-anchored authentication prevents provenance forgery.",
      "Automatic synchronization with Base L2 smart contracts.",
    ],
    securityGuarantee: "Level 1 SUN CMAC token authentication guarantees chip physical presence.",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: ArtisticBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // macOS Brand Pill & Help Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppTheme.goldenGateOrange,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Icon(Icons.fingerprint, size: 12, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Arthentic',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const FeatureHelpButton(helpData: _welcomeHelp),
                  ],
                ),
                const Spacer(),

                // Hero Tagline
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.goldenGateOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "PHYSICAL-TO-DIGITAL PROTOCOL",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.goldenGateOrange,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Every canvas\nhas a fingerprint.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    height: 1.1,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Cryptographically bind physical canvas paintings to verifiable on-chain digital identities on Base L2 using iPhone LiDAR depth scanning & tamper-evident NFC DNA tags.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 36),

                // Primary Action: Sign In
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.goldenGateOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      shadowColor: AppTheme.goldenGateOrange.withValues(alpha: 0.3),
                    ),
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Secondary Action: Create Account
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      side: const BorderSide(color: AppTheme.borderLight, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Create Account',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Guest Mode Action
                Center(
                  child: TextButton(
                    onPressed: () {
                      appLockService.isGuest = true;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MainTabShell()),
                      );
                    },
                    child: Text(
                      'Continue as guest',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.goldenGateOrange,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
