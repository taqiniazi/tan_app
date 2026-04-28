import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tan_network/providers/balance_provider.dart';
import 'package:tan_network/providers/withdrawal_provider.dart';
import 'package:tan_network/theme/app_theme.dart';
import 'package:tan_network/widgets/crypto_text_field.dart';
import 'package:tan_network/widgets/logout_button.dart';
import 'package:tan_network/widgets/ad_banner.dart';

class WithdrawalScreen extends ConsumerStatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  ConsumerState<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends ConsumerState<WithdrawalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedNetwork = 'BSC';
  final double _minWithdrawal = 100.0;

  @override
  void dispose() {
    _amountController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      await ref.read(withdrawalProvider.notifier).submit(
            amount,
            _addressController.text.trim(),
            _selectedNetwork,
          );

      final state = ref.read(withdrawalProvider);
      if (state.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Withdrawal submitted successfully!'), backgroundColor: AppColors.primary),
          );
          Navigator.of(context).pop();
        }
      } else if (state.error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final withdrawalState = ref.watch(withdrawalProvider);
    final balance = ref.watch(balanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WITHDRAW TAN'),
        actions: [const AppLogoutButton(), const SizedBox(width: 8)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBalanceInfo(balance),
              const SizedBox(height: 32),
              CryptoTextField(
                controller: _amountController,
                label: 'Amount',
                icon: Icons.account_balance_wallet_outlined,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  final amount = double.tryParse(val);
                  if (amount == null) return 'Invalid number';
                  if (amount < _minWithdrawal) return 'Min withdrawal is $_minWithdrawal';
                  if (amount > balance) return 'Insufficient balance';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CryptoTextField(
                controller: _addressController,
                label: 'Wallet Address',
                icon: Icons.qr_code_scanner,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _buildNetworkDropdown(),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                ),
                child: const Text('WITHDRAWAL DISABLED'),
              ),
              const SizedBox(height: 12),
              const Text(
                'Feature temporarily unavailable due to maintenance.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.error, fontSize: 12),
              ),
              const SizedBox(height: 32),
              AdBannerPlaceholder(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceInfo(double balance) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          const Text('Available Balance', style: TextStyle(color: AppColors.textSecondary)),
          Text(
            '${balance.toStringAsFixed(2)} TAN',
            style: const TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedNetwork,
      dropdownColor: AppColors.card,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: 'Network',
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: const Icon(Icons.hub_outlined, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.card.withValues(alpha: 0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      items: ['BSC', 'ETH', 'SOL'].map((net) {
        return DropdownMenuItem(value: net, child: Text(net));
      }).toList(),
      onChanged: (val) => setState(() => _selectedNetwork = val!),
    );
  }
}
