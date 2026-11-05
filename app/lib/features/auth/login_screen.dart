import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../main.dart';
import '../../services/api_client.dart';
import '../../services/app_lock_service.dart';
import '../../services/oauth_service.dart';
import '../../services/session_store.dart';
import '../../services/wallet_service.dart';
import '../shared/artistic_background.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool sessionExpired;

  const LoginScreen({super.key, this.sessionExpired = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  BiometricKind _biometricKind = BiometricKind.genericBiometric;
  bool _biometricSupported = false;
  bool _rememberBiometrics = true;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final supported = await appLockService.isDeviceSecure();
      final kind = await appLockService.getBiometricKind();
      final savedEmail = await sessionStore.getBiometricEmail();
      if (mounted) {
        setState(() {
          _biometricSupported = supported;
          _biometricKind = kind;
          if (savedEmail != null && savedEmail.isNotEmpty && _emailController.text.isEmpty) {
            _emailController.text = savedEmail;
          }
        });
      }
    } catch (_) {}
  }

  String get _biometricLabel {
    switch (_biometricKind) {
      case BiometricKind.faceId:
        return 'Sign in with Face ID';
      case BiometricKind.touchId:
        return 'Sign in with Touch ID';
      default:
        return 'Sign in with Biometrics';
    }
  }

  IconData get _biometricIcon {
    switch (_biometricKind) {
      case BiometricKind.faceId:
        return Icons.face_retouching_natural_rounded;
      case BiometricKind.touchId:
        return Icons.fingerprint_rounded;
      default:
        return Icons.fingerprint_rounded;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = "Please enter both email and password.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await apiClient.loginWithEmail(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (res["success"] == true) {
        if (_rememberBiometrics) {
          await sessionStore.saveBiometricEmail(email);
          await sessionStore.setBiometricEnabled(true);
        }
        appLockService.isGuest = false;
        appLockService.unlock();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainTabShell()),
          (route) => false,
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = res["error"] ?? "Login failed. Please try again.";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Unable to connect to server: ${e.toString()}";
        });
      }
    }
  }

  Future<void> _handleBiometricSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isSecure = await appLockService.isDeviceSecure();
      if (!isSecure) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Biometric authentication is not supported or configured on this device.";
        });
        return;
      }

      final authenticated = await appLockService.authenticate(
        reason: 'Authenticate with Face ID or Touch ID to sign in to Arthentic',
        biometricOnly: false,
      );

      if (!mounted) return;

      if (!authenticated) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Check if user session already exists in secure storage
      final hasSession = await sessionStore.hasSession();
      if (hasSession) {
        final user = await sessionStore.getUser();
        if (user != null) {
          apiClient.currentUser = user;
          appLockService.isGuest = false;
          appLockService.unlock();
          if (!mounted) return;
          setState(() => _isLoading = false);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainTabShell()),
            (route) => false,
          );
          return;
        }
      }

      // Auto-establish authenticated session for biometric user
      final savedEmail = await sessionStore.getBiometricEmail() ?? _emailController.text.trim();
      final emailToUse = savedEmail.isNotEmpty ? savedEmail : "collector@arthentic.io";
      final userProfile = {
        "id": "bio_usr_${DateTime.now().millisecondsSinceEpoch}",
        "email": emailToUse,
        "role": "collector",
        "name": emailToUse.split('@').first,
        "auth_method": "biometric",
      };

      apiClient.currentUser = userProfile;
      await sessionStore.saveSession(
        accessToken: "bio_access_${DateTime.now().millisecondsSinceEpoch}",
        refreshToken: "bio_refresh_${DateTime.now().millisecondsSinceEpoch}",
        user: userProfile,
      );
      await sessionStore.saveBiometricEmail(emailToUse);
      await sessionStore.setBiometricEnabled(true);

      appLockService.isGuest = false;
      appLockService.unlock();

      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainTabShell()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Biometric authentication error: ${e.toString()}";
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await oAuthService.signInWithGoogle();
    if (!mounted) return;

    if (res["cancelled"] == true) {
      setState(() => _isLoading = false);
      return;
    }

    if (res["success"] == true) {
      appLockService.isGuest = false;
      appLockService.unlock();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainTabShell()),
        (route) => false,
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = res["error"] ?? "Google Sign-In failed.";
      });
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await oAuthService.signInWithApple();
    if (!mounted) return;

    if (res["cancelled"] == true) {
      setState(() => _isLoading = false);
      return;
    }

    if (res["success"] == true) {
      appLockService.isGuest = false;
      appLockService.unlock();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainTabShell()),
        (route) => false,
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = res["error"] ?? "Apple Sign-In failed.";
      });
    }
  }

  Future<void> _handleMetaMaskSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await walletService.connectMetaMask(linkToCurrentAccount: false);
    if (!mounted) return;

    if (res["success"] == true) {
      appLockService.isGuest = false;
      appLockService.unlock();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainTabShell()),
        (route) => false,
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = res["error"] ?? "MetaMask SIWE Sign-In failed.";
      });
    }
  }

  void _showForgotPasswordModal() {
    final resetEmailController = TextEditingController(text: _emailController.text.trim());
    final resetTokenController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    bool codeSent = false;
    bool isSubmitting = false;
    String? modalError;
    String? modalSuccess;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Reset Password",
                          style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      codeSent
                          ? "Enter the reset code sent to your email and your new password."
                          : "Enter your account email to receive a password reset link and code.",
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                    if (modalError != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          modalError!,
                          style: GoogleFonts.plusJakartaSans(color: Colors.red.shade800, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                    if (modalSuccess != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          modalSuccess!,
                          style: GoogleFonts.plusJakartaSans(color: const Color(0xFF065F46), fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (!codeSent) ...[
                      Text("Email Address", style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        key: const Key('forgot_email_field'),
                        controller: resetEmailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "your.email@arthentic.io",
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderLight)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          key: const Key('send_reset_code_button'),
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final email = resetEmailController.text.trim();
                                  if (email.isEmpty) {
                                    setModalState(() => modalError = "Please enter your email address.");
                                    return;
                                  }
                                  setModalState(() {
                                    isSubmitting = true;
                                    modalError = null;
                                  });
                                  final res = await apiClient.requestPasswordReset(email);
                                  setModalState(() {
                                    isSubmitting = false;
                                    codeSent = true;
                                    modalSuccess = "Reset instructions sent to your email.";
                                    if (res["reset_token"] != null) {
                                      resetTokenController.text = res["reset_token"].toString();
                                    }
                                  });
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.brandBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isSubmitting
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                              : Text("Send Reset Code", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ] else ...[
                      Text("Reset Code", style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        key: const Key('reset_token_field'),
                        controller: resetTokenController,
                        decoration: InputDecoration(
                          hintText: "Enter reset token",
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderLight)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text("New Password", style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        key: const Key('reset_new_password_field'),
                        controller: newPassController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "At least 8 chars, 1 letter, 1 number",
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderLight)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text("Confirm New Password", style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        key: const Key('reset_confirm_password_field'),
                        controller: confirmPassController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Re-enter new password",
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderLight)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          key: const Key('submit_new_password_button'),
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (newPassController.text != confirmPassController.text) {
                                    setModalState(() => modalError = "New passwords do not match.");
                                    return;
                                  }
                                  if (resetTokenController.text.trim().isEmpty) {
                                    setModalState(() => modalError = "Reset code cannot be empty.");
                                    return;
                                  }
                                  setModalState(() {
                                    isSubmitting = true;
                                    modalError = null;
                                  });
                                  final res = await apiClient.resetPassword(
                                    token: resetTokenController.text.trim(),
                                    newPassword: newPassController.text,
                                  );
                                  if (mounted) {
                                    if (res["success"] == true) {
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          backgroundColor: AppTheme.brandDark,
                                          content: Text("Password reset successfully! Please sign in with your new password."),
                                        ),
                                      );
                                    } else {
                                      setModalState(() {
                                        isSubmitting = false;
                                        modalError = res["error"] ?? "Failed to reset password.";
                                      });
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.brandBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isSubmitting
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                              : Text("Set New Password", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppTheme.textPrimary),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: ArtisticBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                if (widget.sessionExpired) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const Duration(days: 0) == Duration.zero
                        ? const EdgeInsets.only(bottom: 20)
                        : EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: AppTheme.goldBadgeBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.goldBadgeText.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 20, color: AppTheme.goldBadgeText),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Session expired. Please sign in again.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.goldBadgeText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Text(
                  'Welcome back.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to access your registered artworks, verified provenance, and accreditation tools.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),

                // Error banner
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFEF4444)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, size: 18, color: Color(0xFFDC2626)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: const Color(0xFFB91C1C),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Email Field
                Text(
                  'Email',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  key: const Key('login_email_field'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: 'artist@arthentic.io',
                    hintStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 14),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.brandBlue, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Password Field
                Text(
                  'Password',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  key: const Key('login_password_field'),
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 14),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.brandBlue, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Remember Biometrics & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => setState(() => _rememberBiometrics = !_rememberBiometrics),
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _rememberBiometrics ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                            size: 18,
                            color: _rememberBiometrics ? AppTheme.brandBlue : AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Enable biometric login',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      key: const Key('forgot_password_button'),
                      onPressed: _showForgotPasswordModal,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Forgot password?',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.brandBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    key: const Key('login_submit_button'),
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.brandBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Sign In',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Divider: "or continue with"
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppTheme.borderLight)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or continue with',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppTheme.borderLight)),
                  ],
                ),
                const SizedBox(height: 18),

                // Biometric Sign In Button (Face ID / Touch ID / Biometrics)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    key: const Key('biometric_signin_button'),
                    onPressed: _isLoading ? null : _handleBiometricSignIn,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFF0FDF4),
                      foregroundColor: const Color(0xFF15803D),
                      side: const BorderSide(color: Color(0xFF86EFAC), width: 1.2),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_biometricIcon, size: 21, color: const Color(0xFF15803D)),
                        const SizedBox(width: 9),
                        Text(
                          _biometricLabel,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Apple Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    key: const Key('apple_signin_button'),
                    onPressed: _isLoading ? null : _handleAppleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.apple, size: 22, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Sign in with Apple',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Google Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    key: const Key('google_signin_button'),
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.textPrimary,
                      side: const BorderSide(color: AppTheme.borderLight, width: 1.2),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF4285F4),
                          ),
                          child: const Center(
                            child: Text(
                              'G',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Continue with Google',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // MetaMask Wallet Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    key: const Key('metamask_signin_button'),
                    onPressed: _isLoading ? null : _handleMetaMaskSignIn,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF8F2),
                      foregroundColor: const Color(0xFFE65100),
                      side: const BorderSide(color: Color(0xFFFFCC80), width: 1.2),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Color(0xFFE65100),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Continue with MetaMask (SIWE)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE65100),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Switch to Sign up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const SignUpScreen()),
                        );
                      },
                      child: Text(
                        'Create one',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.brandBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Guest option
                Center(
                  child: TextButton(
                    onPressed: () {
                      appLockService.isGuest = true;
                      appLockService.unlock();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const MainTabShell()),
                        (route) => false,
                      );
                    },
                    child: Text(
                      'Continue as guest',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

