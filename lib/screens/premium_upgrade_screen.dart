import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tan_network/services/api_service.dart';
import 'package:tan_network/theme/app_theme.dart';
import 'package:tan_network/widgets/crypto_text_field.dart';
import 'package:tan_network/widgets/logout_button.dart';
import 'package:tan_network/widgets/ad_banner.dart';

class PremiumUpgradeScreen extends ConsumerStatefulWidget {
  const PremiumUpgradeScreen({super.key});

  @override
  ConsumerState<PremiumUpgradeScreen> createState() =>
      _PremiumUpgradeScreenState();
}

class _PremiumUpgradeScreenState extends ConsumerState<PremiumUpgradeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _txController = TextEditingController();
  String _selectedNetwork = 'BSC';
  Map<String, dynamic>? _config;
  bool _isLoadingConfig = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchConfig();
  }

  Future<void> _fetchConfig() async {
    final config = await ref.read(apiServiceProvider).getConfig();
    if (mounted) {
      setState(() {
        _config = config;
        _isLoadingConfig = false;
      });
    }
  }

  @override
  void dispose() {
    _txController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Address copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      try {
        await ref
            .read(apiServiceProvider)
            .verifyPayment(_txController.text.trim(), _selectedNetwork);
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.card,
              title: const Text(
                'Upgrade Successful!',
                style: TextStyle(color: AppColors.primary),
              ),
              content: const Text(
                'Your account has been upgraded to Premium. Enjoy 10x mining speed!',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Pop dialog
                    Navigator.of(context).pop(); // Pop screen
                  },
                  child: const Text('AWESOME'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingConfig) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    String address = 'N/A';
    if (_config != null) {
      address = (_selectedNetwork == 'SOL')
          ? (_config!['paymentAddressSOL'] ?? 'N/A')
          : (_config!['paymentAddressEVM'] ?? 'N/A');
    }

    final fee = _config?['premiumFee']?.toDouble() ?? 10.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('UPGRADE TO PREMIUM'),
        actions: [const AppLogoutButton(), const SizedBox(width: 8)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPlanInfo(fee),
              const SizedBox(height: 32),
              _buildNetworkSelection(),
              const SizedBox(height: 24),
              _buildPaymentInstructions(address),
              const SizedBox(height: 32),
              CryptoTextField(
                controller: _txController,
                label: 'Transaction Hash (TXID)',
                icon: Icons.receipt_long_rounded,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('VERIFY & UPGRADE'),
              ),
              const SizedBox(height: 32),
              AdBannerPlaceholder(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanInfo(double fee) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accent, Color(0xFF6A1B9A)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.star_rounded, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          const Text(
            'LIFETIME PREMIUM',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$$fee USDT',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '• 10x Mining Speed\n• Priority Withdrawals\n• Exclusive Badge',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Payment Network',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Row(
          children: ['BSC', 'ETH', 'SOL'].map((net) {
            final isSelected = _selectedNetwork == net;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedNetwork = net),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      net,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPaymentInstructions(String address) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Send exactly \$10 USDT to the address below:',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  address,
                  style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.copy_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
                onPressed: () => _copyToClipboard(address),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
