import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme.dart';
import 'features/auth/app_lock_gate.dart';
import 'features/auth/splash_screen.dart';
import 'features/home/home_screen.dart';
import 'features/provenance/provenance_screen.dart';
import 'features/wallet/wallet_screen.dart';
import 'features/marketplace/marketplace_screen.dart';
import 'features/web_consoles/gallery_safe_console.dart';
import 'features/web_consoles/conservator_console.dart';
import 'features/web_consoles/admin_incident_console.dart';
import 'features/web_consoles/consoles_hub_screen.dart';
import 'features/verify/public_nfc_tap_screen.dart';
import 'features/genesis/genesis_intake_screen.dart';
import 'features/genesis/coa_screen.dart';
import 'features/conservation/restoration_screen.dart';
import 'features/dashboards/artist_dashboard.dart';
import 'features/dashboards/collector_dashboard.dart';
import 'services/api_client.dart';
import 'services/wallet_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ArthenticApp());
}

class ArthenticApp extends StatelessWidget {
  final Widget? home;
  final String? initialRoute;

  const ArthenticApp({super.key, this.home, this.initialRoute});

  static Widget? _resolveDeepLinkWidget(String? routeStr) {
    if (routeStr == null || routeStr.isEmpty) return null;
    final uri = Uri.tryParse(routeStr);
    if (uri == null) return null;
    final path = uri.path.toLowerCase();

    // 1. D-14* Zero-Install Public NFC Tap Web Viewer
    if (path.contains('/verify')) {
      final uid = uri.queryParameters['uid'] ?? '04A1B2C3D4E580';
      final ctr = int.tryParse(uri.queryParameters['ctr'] ?? '1') ?? 1;
      final cmac = uri.queryParameters['cmac'] ?? 'A9E38F107B5C2D44';
      return PublicNfcTapScreen(uid: uid, ctr: ctr, cmac: cmac);
    }

    // 2. B-12 Public Certificate of Authenticity (CoA)
    if (path.contains('/coa')) {
      final tokenId = uri.queryParameters['tokenId'] ??
          (uri.pathSegments.length > 1 ? uri.pathSegments[1] : '101');
      return CertificateOfAuthenticityScreen(tokenId: tokenId);
    }

    // 3. Institutional Consoles
    if (path.contains('/console/gallery') || path.contains('/gallery')) {
      return const GallerySafeConsole();
    }
    if (path.contains('/console/conservator') || path.contains('/conservator')) {
      return const ConservatorStudioConsole();
    }
    if (path.contains('/console/admin') || path.contains('/governance')) {
      return const AdminIncidentConsole();
    }

    // 4. Genesis Intake Wizard
    if (path.contains('/intake') || path.contains('/genesis')) {
      return const GenesisIntakeScreen();
    }

    // 5. Restoration & 3-of-3 Chip Governance
    if (path.contains('/restoration')) {
      final tokenId = uri.queryParameters['tokenId'] ?? '101';
      return RestorationScreen(tokenId: tokenId);
    }

    // 6. Dashboards
    if (path.contains('/dashboard/artist')) {
      return const ArtistDashboardScreen();
    }
    if (path.contains('/dashboard/collector')) {
      return const CollectorDashboardScreen();
    }

    final uid = uri.queryParameters['uid'];
    if (uid != null && uid.isNotEmpty) {
      final ctr = int.tryParse(uri.queryParameters['ctr'] ?? '1') ?? 1;
      final cmac = uri.queryParameters['cmac'] ?? 'A9E38F107B5C2D44';
      return PublicNfcTapScreen(uid: uid, ctr: ctr, cmac: cmac);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final deepLinked = _resolveDeepLinkWidget(initialRoute) ??
        _resolveDeepLinkWidget(Uri.base.toString());
    return MaterialApp(
      title: 'Arthentic Protocol',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: home ?? deepLinked ?? const SplashScreen(),
    );
  }
}

class MainTabShell extends StatefulWidget {
  final int initialIndex;
  const MainTabShell({super.key, this.initialIndex = 0});

  @override
  State<MainTabShell> createState() => _MainTabShellState();
}

class _MainTabShellState extends State<MainTabShell> {
  late int _currentIndex;
  int _consoleSubIndex = 0;

  @override
  void initState() {
    super.initState();
    // Resolve initial index gracefully (supports both 5-tab system and legacy indices)
    _resolveTabAndSubIndex(widget.initialIndex);
    _initApp();
  }

  void _resolveTabAndSubIndex(int index) {
    if (index == 1 && widget.initialIndex == 1) {
      _currentIndex = 1; // Market
    } else if (index == 2) {
      // If legacy requested Gallery Safe (index 2 in 7-tab), route to Consoles tab with Gallery Safe
      _currentIndex = 3;
      _consoleSubIndex = 0;
    } else if (index == 3) {
      // If legacy requested Conservator (index 3 in 7-tab), route to Consoles tab with Conservator
      _currentIndex = 3;
      _consoleSubIndex = 1;
    } else if (index == 4) {
      _currentIndex = 4; // Wallet
    } else if (index == 5) {
      _currentIndex = 1; // Market (legacy index 5)
    } else if (index == 6) {
      _currentIndex = 3; // Governance (legacy index 6)
      _consoleSubIndex = 2;
    } else {
      _currentIndex = index.clamp(0, 4);
    }
  }

  Future<void> _initApp() async {
    if (apiClient.accessToken == null) {
      final restored = await apiClient.restoreSession();
      if (!restored) {
        await apiClient.login(walletService.address);
      }
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _resolveTabAndSubIndex(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 5 Clean Core Tabs:
    // 0: Verify (Home, LiDAR scan, NFC tap, Artwork Intake)
    // 1: Market (Marketplace Listings, Carrier Escrow)
    // 2: Provenance (On-Chain Provenance Ledger, CoA Viewers)
    // 3: Consoles (Unified Institutional Hub: Gallery Safe, Conservator Studio, Governance)
    // 4: Wallet (Account, Paymaster Gas, Custody)
    final allScreens = [
      HomeScreen(onTabSelected: _onTabSelected),
      const MarketplaceScreen(),
      const ProvenanceScreen(),
      ConsolesHubScreen(
        initialConsoleIndex: _consoleSubIndex,
        key: ValueKey('console_hub_$_consoleSubIndex'),
      ),
      const WalletScreen(),
    ];

    final isConsoleTab = _currentIndex == 3;
    final maxContentWidth = isConsoleTab ? 1080.0 : 580.0;

    return AppLockGate(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F8),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Container(
              color: Colors.white,
              child: IndexedStack(
                index: _currentIndex < allScreens.length ? _currentIndex : 0,
                children: allScreens,
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(
              top: BorderSide(color: Color(0xFFEBEBEB), width: 1.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 68,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 580),
                  child: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    currentIndex: _currentIndex < allScreens.length ? _currentIndex : 0,
                    onTap: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    elevation: 0,
                    backgroundColor: Colors.white,
                    selectedItemColor: const Color(0xFFFF385C), // Airbnb Coral
                    unselectedItemColor: const Color(0xFF717171),
                    selectedFontSize: 11,
                    unselectedFontSize: 11,
                    selectedLabelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFF385C),
                    ),
                    unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF717171),
                    ),
                    items: const [
                      BottomNavigationBarItem(
                        icon: Padding(
                          padding: EdgeInsets.only(bottom: 2),
                          child: Icon(Icons.verified_user_outlined),
                        ),
                        activeIcon: Padding(
                          padding: EdgeInsets.only(bottom: 2),
                          child: Icon(Icons.verified_user_rounded),
                        ),
                        label: 'Verify',
                      ),
                      BottomNavigationBarItem(
                        icon: Padding(
                          padding: EdgeInsets.only(bottom: 2),
                          child: Icon(Icons.storefront_outlined),
                        ),
                        activeIcon: Padding(
                          padding: EdgeInsets.only(bottom: 2),
                          child: Icon(Icons.storefront_rounded),
                        ),
                        label: 'Market',
                      ),
                      BottomNavigationBarItem(
                        icon: Padding(
                          padding: EdgeInsets.only(bottom: 2),
                          child: Icon(Icons.history_edu_outlined),
                        ),
                        activeIcon: Padding(
                          padding: EdgeInsets.only(bottom: 2),
                          child: Icon(Icons.history_edu_rounded),
                        ),
                        label: 'Provenance',
                      ),
                      BottomNavigationBarItem(
                        icon: Padding(
                          padding: EdgeInsets.only(bottom: 2),
                          child: Icon(Icons.hub_outlined),
                        ),
                        activeIcon: Padding(
                          padding: EdgeInsets.only(bottom: 2),
                          child: Icon(Icons.hub_rounded),
                        ),
                        label: 'Consoles',
                      ),
                      BottomNavigationBarItem(
                        icon: Padding(
                          padding: EdgeInsets.only(bottom: 2),
                          child: Icon(Icons.account_balance_wallet_outlined),
                        ),
                        activeIcon: Padding(
                          padding: EdgeInsets.only(bottom: 2),
                          child: Icon(Icons.account_balance_wallet_rounded),
                        ),
                        label: 'Wallet',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
