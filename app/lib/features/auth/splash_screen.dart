import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../main.dart';
import '../../services/session_store.dart';
import '../../services/api_client.dart';
import '../../services/app_lock_service.dart';
import '../shared/artistic_background.dart';
import 'login_screen.dart';
import 'welcome_screen.dart';

class OnboardingSlide {
  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;
  final String imagePath;
  final String networkImageUrl;
  final List<String> highlights;

  const OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.imagePath,
    required this.networkImageUrl,
    required this.highlights,
  });
}

class SplashScreen extends StatefulWidget {
  final bool autoRoute;

  const SplashScreen({super.key, this.autoRoute = false});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoSlideTimer;

  final List<OnboardingSlide> _slides = const [
    OnboardingSlide(
      title: "Micro-Topological\nCanvas Fingerprint",
      subtitle:
          "Pairs iPhone LiDAR 3D spatial depth point clouds with high-res optical weave analysis to identify the unique physical biometric of every oil painting.",
      badge: "Level 2 Intrinsic Biometric",
      icon: Icons.view_in_ar_rounded,
      imagePath: "assets/images/canvas_sample_1.jpg",
      networkImageUrl:
          "https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?auto=format&fit=crop&w=800&q=80",
      highlights: ["0.2mm Depth Precision", "320Hz Weave Extraction", "Anti-Counterfeit Gate"],
    ),
    OnboardingSlide(
      title: "Tamper-Evident\nNTAG 424 DNA NFC",
      subtitle:
          "Physical conductive loop embedded into the stretcher frame breaks permanently upon removal. Dynamic AES-128 SUN CMAC prevents chip cloning.",
      badge: "Level 1 Physical Hardware",
      icon: Icons.nfc_rounded,
      imagePath: "assets/images/canvas_sample_3.jpg",
      networkImageUrl:
          "https://images.unsplash.com/photo-1578328819058-b69f3a3b0f6b?auto=format&fit=crop&w=800&q=80",
      highlights: ["TAMPER_PERM_OPEN", "Zero-Install Public Tap", "Dynamic CMAC Key"],
    ),
    OnboardingSlide(
      title: "Decentralized Escrow\n& Base L2 Settlement",
      subtitle:
          "EIP-712 structured cryptographic signatures settle on Base L2. Escrow funds unlock automatically only when buyer-verified LiDAR delivery confirms authenticity.",
      badge: "Base L2 · EVM Verified",
      icon: Icons.account_balance_wallet_rounded,
      imagePath: "assets/images/canvas_sample_2.jpg",
      networkImageUrl:
          "https://images.unsplash.com/photo-1541701494587-cb58502866ab?auto=format&fit=crop&w=800&q=80",
      highlights: ["Trustless Delivery", "Automated Royalties", "48h Dispute Timelock"],
    ),
    OnboardingSlide(
      title: "Institutional Studio\n& Arweave Archives",
      subtitle:
          "Galleries and certified conservators manage multi-sig Safe treasury, permanent treatment dossiers on Arweave, and 3-of-3 chip replacement governance.",
      badge: "Gnosis Safe · Arweave Permanent",
      icon: Icons.biotech_rounded,
      imagePath: "assets/images/canvas_sample_4.jpg",
      networkImageUrl:
          "https://images.unsplash.com/photo-1577083552431-6e5fd01aa342?auto=format&fit=crop&w=800&q=80",
      highlights: ["Permanent Dossiers", "3-of-3 Chip Replacement", "Safe 2-of-3 Multisig"],
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Gentle auto-slide timer that stops once user interacts
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (_currentPage < _slides.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _proceedToApp() async {
    _autoSlideTimer?.cancel();
    final hasStoredSession = await sessionStore.hasSession();
    if (!mounted) return;

    if (!hasStoredSession) {
      appLockService.isGuest = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
      return;
    }

    final restored = await apiClient.restoreSession();
    if (!mounted) return;

    if (restored) {
      appLockService.isGuest = false;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainTabShell()),
      );
    } else {
      appLockService.isGuest = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(sessionExpired: true),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: ArtisticBackground(
        child: SafeArea(
          child: Column(
            children: [
              // macOS Header Bar with Brand & Skip
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppTheme.goldenGateOrange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.fingerprint, size: 13, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Arthentic Protocol",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Skip Button
                    TextButton(
                      onPressed: _proceedToApp,
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        "Skip",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Swipeable Slides Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (idx) {
                    setState(() => _currentPage = idx);
                  },
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return _buildSlideCard(slide);
                  },
                ),
              ),

              // Bottom Control Area: Indicator & CTA
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dots Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (i) {
                        final isActive = _currentPage == i;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 28 : 8,
                          height: 7,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppTheme.goldenGateOrange
                                : const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    // Primary Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage < _slides.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _proceedToApp();
                          }
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentPage == _slides.length - 1
                                  ? "Get Started"
                                  : "Next Advantage",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _currentPage == _slides.length - 1
                                  ? Icons.arrow_forward_rounded
                                  : Icons.chevron_right_rounded,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Direct Sign In Shortcut
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          "Already have an account? Sign In",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlideCard(OnboardingSlide slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Visual Artwork Image Container (macOS Squircle Frame)
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.borderLight, width: 1.2),
                boxShadow: AppTheme.macCardShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(23),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Artwork Image with Fallback
                    Image.asset(
                      slide.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) {
                        return Image.network(
                          slide.networkImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: const Color(0xFFF1F5F9),
                            child: Center(
                              child: Icon(
                                slide.icon,
                                size: 54,
                                color: AppTheme.goldenGateOrange.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Subtle Frosted Gradient Overlay
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.45),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Top Floating Badge
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(slide.icon, size: 14, color: AppTheme.goldenGateOrange),
                            const SizedBox(width: 6),
                            Text(
                              slide.badge,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Highlight tags at bottom of image
                    Positioned(
                      bottom: 14,
                      left: 14,
                      right: 14,
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: slide.highlights.map((h) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              h,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Slide Title & Subtitle
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slide.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      height: 1.15,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    slide.subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      color: AppTheme.textSecondary,
                      height: 1.5,
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
}
