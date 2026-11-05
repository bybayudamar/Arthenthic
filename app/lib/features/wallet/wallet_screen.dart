import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme.dart';
import '../../services/wallet_service.dart';
import '../shared/artistic_background.dart';
import '../shared/feature_help_dialog.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String _selectedRoleFilter = "Collector";
  bool _isSigning = false;

  static const List<String> _roleTabs = [
    "Collector",
    "Artist",
    "Secondary Buyer",
    "Verifier",
    "Conservator",
    "Admin",
  ];

  void _copyAddress() {
    Clipboard.setData(ClipboardData(text: walletService.address));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.brandDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Text("Address copied to clipboard"),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showQrDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          "WalletConnect / MetaMask QR",
          style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: QrImageView(
                data: walletService.address,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              walletService.address,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showMetaMaskConnectModal() {
    final addrCtrl = TextEditingController(text: walletService.address);
    bool isLinking = false;

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Color(0xFFE65100),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Connect MetaMask Wallet",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Connect via WalletConnect v2 (metamask://wc) on Base Sepolia (Chain ID: 84532) and sign SIWE (EIP-4361) verification.",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "MetaMask EOA Address",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: addrCtrl,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.bgLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.borderLight),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLinking
                          ? null
                          : () async {
                              setModalState(() => isLinking = true);
                              await walletService.connectMetaMask(
                                customAddress: addrCtrl.text,
                                linkToCurrentAccount: true,
                              );
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (mounted) {
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: const Color(0xFFE65100),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    content: const Text("MetaMask EOA connected & linked via SIWE!"),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE65100),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.bolt_rounded, size: 18),
                      label: Text(
                        isLinking ? "Signing SIWE in MetaMask..." : "Sign & Link MetaMask (EIP-4361)",
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showMetaMaskActionSheet(RoleMetaMaskFlowItem item) {
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
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "MetaMask · ${item.code} · ${item.role}",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFE65100),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.bgLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Target Contract / EIP-712 Domain:",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.contractCall,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "RPC Method: ${item.signingMethod}",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Gas Policy: ${item.gasModel}",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.brandBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSigning
                          ? null
                          : () async {
                              setModalState(() => _isSigning = true);
                              final res = await walletService.signAndExecuteRoleAction(item);
                              setModalState(() => _isSigning = false);
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (mounted) {
                                final ok = res["success"] == true;
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: ok ? AppTheme.brandDark : Colors.red.shade700,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    content: Text(
                                      ok
                                          ? "Signed ${item.code} (${item.title}) via MetaMask!"
                                          : (res["error"] ?? "Action failed"),
                                    ),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE65100),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.verified_user_rounded, size: 18),
                      label: Text(
                        _isSigning ? "Awaiting MetaMask Signature..." : "Confirm Signature in MetaMask",
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static const FeatureHelpData _walletHelp = FeatureHelpData(
    title: "Web3 Smart Wallet & Paymaster",
    subtitle: "Non-custodial custody & gasless transaction management",
    icon: Icons.account_balance_wallet_rounded,
    howToUse: [
      "Select your wallet provider: MetaMask EOA, Passkey Smart Wallet, or Gnosis Safe Multisig.",
      "Filter role flows (Collector, Artist, Verifier, Conservator) to execute role-specific on-chain transactions.",
      "Sign EIP-712 structured messages for artwork transfers, minting, or escrow claims with zero gas fees.",
    ],
    benefits: [
      "ERC-4337 Account Abstraction: Gas fees are sponsored by the protocol paymaster.",
      "Biometric Passkey login: Secure cryptographic signing using iPhone FaceID / TouchID.",
      "Gnosis Safe integration: Multi-sig security for high-value artwork custody.",
    ],
    securityGuarantee: "Non-custodial keys: Private keys never touch any centralized server.",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: ArtisticBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AnimatedBuilder(
              animation: walletService,
              builder: (context, _) {
                final roleItems = walletService.flowsForRole(_selectedRoleFilter);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Headline
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Your wallet.",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const FeatureHelpButton(helpData: _walletHelp),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Wallet Provider Switcher (MetaMask EOA / Passkey Smart Wallet / Safe Multisig)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.account_balance_wallet_rounded,
                                    color: Color(0xFFE65100),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    walletService.walletProvider,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: _showMetaMaskConnectModal,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  "Link MetaMask",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFE65100),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                "MetaMask Mobile (EOA)",
                                "Passkey Smart Wallet",
                                "Safe Multisig",
                              ].map((provider) {
                                final active = walletService.walletProvider == provider;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(
                                      provider,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: active ? Colors.white : AppTheme.textPrimary,
                                      ),
                                    ),
                                    selected: active,
                                    selectedColor: const Color(0xFFE65100),
                                    backgroundColor: AppTheme.bgLight,
                                    onSelected: (_) => walletService.switchWalletProvider(provider),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 1: Address Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Smart wallet address",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            walletService.address,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _copyAddress,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.textPrimary,
                                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: Text(
                                    "Copy",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _showQrDialog,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.textPrimary,
                                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: Text(
                                    "Show QR",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 2: Details Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow("Network", walletService.network),
                          _buildRowDivider(),
                          _buildDetailRow("Gas", walletService.gasStatus),
                          _buildRowDivider(),
                          _buildDetailRow("Key storage", walletService.keyStorage),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 3: On-chain roles Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "On-chain roles",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: [
                              // Gold Collector Pill
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.goldBadgeBg,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  "Collector",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.goldBadgeText,
                                  ),
                                ),
                              ),
                              // Lavender Verifier Pill
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF0FA),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  "Verifier · none",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF4B5563),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 4: Role-by-Role MetaMask Flows (Catatan Prototype #1)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "MetaMask Flows by Role (EIP-712 & Escrow)",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Select a role to inspect and test its MetaMask signing flow:",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _roleTabs.map((role) {
                                final isSelected = _selectedRoleFilter == role;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(
                                      role,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                                      ),
                                    ),
                                    selected: isSelected,
                                    selectedColor: AppTheme.brandDark,
                                    backgroundColor: AppTheme.bgLight,
                                    onSelected: (_) => setState(() => _selectedRoleFilter = role),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...roleItems.map((item) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppTheme.bgLight,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppTheme.borderLight),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "${item.code} · ${item.title}",
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => _showMetaMaskActionSheet(item),
                                        style: TextButton.styleFrom(
                                          backgroundColor: const Color(0xFFFFF3E0),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          "Sign via MetaMask",
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFFE65100),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.contractCall,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: AppTheme.brandBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.description,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 5: Recent signatures Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Recent signatures",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...walletService.recentSignatures.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final record = entry.value;
                            return Column(
                              children: [
                                if (idx > 0) _buildRowDivider(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          record.action,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        record.timestamp,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              color: AppTheme.textPrimary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowDivider() {
    return Container(
      height: 1,
      color: AppTheme.borderLight,
    );
  }
}
