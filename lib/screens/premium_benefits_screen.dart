import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tan_network/theme/app_theme.dart';
import 'package:tan_network/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class PremiumBenefitsScreen extends ConsumerWidget {
  const PremiumBenefitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final expiryDate = user?.premiumExpiry != null 
        ? DateFormat('MMM dd, yyyy').format(user!.premiumExpiry!) 
        : 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: const Text('PREMIUM HUB'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusCard(expiryDate),
            const SizedBox(height: 32),
            const Text(
              'YOUR EXCLUSIVE BENEFITS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 20),
            _buildBenefitItem(
              icon: Icons.flash_on_rounded,
              title: '10x Mining Power',
              description: 'Your base mining rate is boosted by 1000% compared to standard users.',
              color: Colors.amber,
            ),
            _buildBenefitItem(
              icon: Icons.speed_rounded,
              title: 'Priority Withdrawals',
              description: 'Your withdrawal requests are moved to the front of the queue for faster processing.',
              color: Colors.blueAccent,
            ),
            _buildBenefitItem(
              icon: Icons.verified_user_rounded,
              title: 'Verified Badge',
              description: 'Stand out in the community and leaderboard with your exclusive premium badge.',
              color: Colors.purpleAccent,
            ),
            _buildBenefitItem(
              icon: Icons.support_agent_rounded,
              title: 'Priority Support',
              description: 'Access to dedicated support channels for faster resolution of any issues.',
              color: Colors.greenAccent,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.card,
                foregroundColor: AppColors.textPrimary,
              ),
              child: const Text('BACK TO DASHBOARD'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String expiryDate) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.stars_rounded, color: Colors.white, size: 64),
          const SizedBox(height: 16),
          const Text(
            'ACTIVE PREMIUM',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your subscription is active until:',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            expiryDate,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
