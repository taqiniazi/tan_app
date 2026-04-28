import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tan_network/providers/auth_provider.dart';
import 'package:tan_network/theme/app_theme.dart';

class AppLogoutButton extends ConsumerWidget {
  const AppLogoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.logout_rounded, color: AppColors.error),
      tooltip: 'Logout',
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.card,
            title: const Text('Logout', style: TextStyle(color: Colors.white)),
            content: const Text('Are you sure you want to logout?', style: TextStyle(color: AppColors.textSecondary)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                },
                child: const Text('LOGOUT', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
      },
    );
  }
}
