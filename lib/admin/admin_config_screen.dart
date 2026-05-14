import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tan_network/services/api_service.dart';
import 'package:tan_network/theme/app_theme.dart';
import 'package:tan_network/widgets/crypto_text_field.dart';

class AdminConfigScreen extends ConsumerStatefulWidget {
  const AdminConfigScreen({super.key});

  @override
  ConsumerState<AdminConfigScreen> createState() => _AdminConfigScreenState();
}

class _AdminConfigScreenState extends ConsumerState<AdminConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;
  // ignore: unused_field
  Map<String, dynamic> _config = {};

  // Controllers
  final _miningRateController = TextEditingController();
  final _premiumMiningRateController = TextEditingController();
  final _referralBonusController = TextEditingController();
  final _minWithdrawalController = TextEditingController();
  final _maxWithdrawalController = TextEditingController();
  final _paymentEvmController = TextEditingController();
  final _paymentSolController = TextEditingController();
  final _premiumFeeController = TextEditingController();
  final _minVersionController = TextEditingController();
  final _updateUrlController = TextEditingController();
  bool _maintenanceMode = false;

  @override
  void initState() {
    super.initState();
    _fetchConfig();
  }

  @override
  void dispose() {
    _miningRateController.dispose();
    _premiumMiningRateController.dispose();
    _referralBonusController.dispose();
    _minWithdrawalController.dispose();
    _maxWithdrawalController.dispose();
    _paymentEvmController.dispose();
    _paymentSolController.dispose();
    _premiumFeeController.dispose();
    _minVersionController.dispose();
    _updateUrlController.dispose();
    super.dispose();
  }

  Future<void> _fetchConfig() async {
    try {
      final config = await ref.read(apiServiceProvider).getConfig();
      if (mounted) {
        setState(() {
          _config = config;
          _miningRateController.text = (config['mining_rate'] ?? config['miningRate'] ?? 0.01).toString();
          _premiumMiningRateController.text = (config['premium_mining_rate'] ?? config['premiumMiningRate'] ?? 0.1).toString();
          _referralBonusController.text = (config['referral_bonus'] ?? config['referralBonus'] ?? 10).toString();
          _minWithdrawalController.text = (config['min_withdrawal'] ?? config['minWithdrawal'] ?? 50).toString();
          _maxWithdrawalController.text = (config['max_withdrawal'] ?? config['maxWithdrawal'] ?? 5000).toString();
          _paymentEvmController.text = config['payment_address_evm'] ?? config['paymentAddressEVM'] ?? '';
          _paymentSolController.text = config['payment_address_sol'] ?? config['paymentAddressSOL'] ?? '';
          _premiumFeeController.text = (config['premium_fee'] ?? config['premiumFee'] ?? 10.0).toString();
          _minVersionController.text = config['min_app_version'] ?? config['minAppVersion'] ?? '1.0.0';
          _updateUrlController.text = config['app_update_url'] ?? config['appUpdateUrl'] ?? '';
          _maintenanceMode = (config['maintenance_mode'] ?? config['maintenanceMode'] ?? false) == true || (config['maintenance_mode'] ?? config['maintenanceMode'] ?? 0) == 1;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching config: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final updatedData = {
        'mining_rate': double.parse(_miningRateController.text),
        'premium_mining_rate': double.parse(_premiumMiningRateController.text),
        'referral_bonus': double.parse(_referralBonusController.text),
        'min_withdrawal': double.parse(_minWithdrawalController.text),
        'max_withdrawal': double.parse(_maxWithdrawalController.text),
        'payment_address_evm': _paymentEvmController.text.trim(),
        'payment_address_sol': _paymentSolController.text.trim(),
        'premium_fee': double.parse(_premiumFeeController.text),
        'min_app_version': _minVersionController.text.trim(),
        'app_update_url': _updateUrlController.text.trim(),
        'maintenance_mode': _maintenanceMode,
      };

      await ref.read(apiServiceProvider).updateConfig(updatedData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuration updated successfully!'), backgroundColor: AppColors.primary),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating config: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Mining & Rewards', Icons.bolt_rounded),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildInput('Base Mining Rate (TAN/h)', _miningRateController)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInput('Premium Mining Rate (TAN/h)', _premiumMiningRateController)),
                ],
              ),
              const SizedBox(height: 16),
              _buildInput('Referral Bonus (%)', _referralBonusController),

              const SizedBox(height: 32),
              _buildSectionHeader('Withdrawal Limits', Icons.account_balance_wallet_rounded),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildInput('Min Withdrawal', _minWithdrawalController)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInput('Max Withdrawal', _maxWithdrawalController)),
                ],
              ),

              const SizedBox(height: 32),
              _buildSectionHeader('Payments (Admin Wallets)', Icons.payments_rounded),
              const SizedBox(height: 16),
              _buildInput('EVM Address (BSC/ETH)', _paymentEvmController),
              const SizedBox(height: 16),
              _buildInput('SOL Address', _paymentSolController),
              const SizedBox(height: 16),
              _buildInput('Premium Upgrade Fee (USDT)', _premiumFeeController),

              const SizedBox(height: 32),
              _buildSectionHeader('System & Updates', Icons.system_update_rounded),
              const SizedBox(height: 16),
              _buildInput('Min App Version', _minVersionController),
              const SizedBox(height: 16),
              _buildInput('App Update URL', _updateUrlController),
              const SizedBox(height: 16),
              _buildMaintenanceToggle(),

              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveConfig,
                  child: _isSaving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('SAVE CONFIGURATION'),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return CryptoTextField(
      controller: controller,
      label: label,
      icon: Icons.edit_rounded,
      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildMaintenanceToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Maintenance Mode', style: TextStyle(color: AppColors.textSecondary)),
          Switch(
            value: _maintenanceMode,
            onChanged: (val) => setState(() => _maintenanceMode = val),
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
