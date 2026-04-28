import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tan_network/providers/auth_provider.dart';
import 'package:tan_network/screens/main_layout.dart';
import 'package:tan_network/screens/signup_screen.dart';
import 'package:tan_network/theme/app_theme.dart';
import 'package:tan_network/widgets/crypto_text_field.dart';
import 'package:tan_network/admin/admin_layout.dart';
import 'package:tan_network/widgets/animations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
      
      final authState = ref.read(authProvider);
      if (authState.user != null) {
        if (mounted) {
          final target = authState.user!.isAdmin ? const AdminLayout() : const MainLayout();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => target),
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FadeSlideTransition(
                  duration: Duration(milliseconds: 500),
                  child: Icon(Icons.lock_person_rounded, size: 80, color: AppColors.primary),
                ),
                const SizedBox(height: 24),
                const FadeSlideTransition(
                  duration: Duration(milliseconds: 600),
                  child: Text(
                    'TAN Network Login',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                const FadeSlideTransition(
                  duration: Duration(milliseconds: 700),
                  child: Text(
                    'Enter your credentials to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 48),
                FadeSlideTransition(
                  duration: const Duration(milliseconds: 800),
                  child: CryptoTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    validator: (val) => val == null || !val.contains('@') ? 'Invalid email' : null,
                  ),
                ),
                const SizedBox(height: 16),
                FadeSlideTransition(
                  duration: const Duration(milliseconds: 900),
                  child: CryptoTextField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    validator: (val) => val == null || val.length < 6 ? 'Min 6 characters' : null,
                  ),
                ),
                const SizedBox(height: 32),
                FadeSlideTransition(
                  duration: const Duration(milliseconds: 1000),
                  child: AnimatedTap(
                    onTap: authState.isLoading ? () {} : _login,
                    child: ElevatedButton(
                      onPressed: authState.isLoading ? null : _login,
                      child: authState.isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('LOGIN'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeSlideTransition(
                  duration: const Duration(milliseconds: 1100),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const SignupScreen()),
                      );
                    },
                    child: const Text('Don\'t have an account? Sign Up', style: TextStyle(color: AppColors.accent)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
