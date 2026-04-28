import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tan_network/providers/auth_provider.dart';
import 'package:tan_network/screens/main_layout.dart';
import 'package:tan_network/theme/app_theme.dart';
import 'package:tan_network/widgets/crypto_text_field.dart';
import 'package:tan_network/widgets/location_picker.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _referralController = TextEditingController();

  String? _selectedCountry;
  String? _selectedState;
  String? _selectedCity;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  void _signup() async {
    if (_selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a country')),
      );
      return;
    }
    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a city')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      await ref.read(authProvider.notifier).signup(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _referralController.text.trim().isEmpty ? null : _referralController.text.trim(),
            _selectedCountry!,
            _selectedCity!,
          );
      
      final authState = ref.read(authProvider);
      if (authState.user != null) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainLayout()),
          );
        }
      } else if (authState.error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authState.error!), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              CryptoTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CryptoTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                validator: (val) => val == null || !val.contains('@') ? 'Invalid email' : null,
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              CustomLocationPicker(
                onCountrySelected: (val) => setState(() => _selectedCountry = val),
                onStateSelected: (val) => setState(() => _selectedState = val),
                onCitySelected: (val) => setState(() => _selectedCity = val),
              ),
              const SizedBox(height: 16),
              CryptoTextField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock_outline,
                isPassword: true,
                validator: (val) => val == null || val.length < 6 ? 'Min 6 characters' : null,
              ),
              const SizedBox(height: 16),
              CryptoTextField(
                controller: _referralController,
                label: 'Referral Code (Optional)',
                icon: Icons.card_giftcard_rounded,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: authState.isLoading ? null : _signup,
                child: authState.isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('CREATE ACCOUNT'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: enabled ? onChanged : null,
      validator: (val) => val == null ? 'Required' : null,
      dropdownColor: AppColors.card,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.card.withValues(alpha: 0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabled: enabled,
      ),
    );
  }
}
