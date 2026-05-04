import 'package:flutter/material.dart';
import 'package:tan_network/theme/app_theme.dart';
import 'package:tan_network/screens/premium_upgrade_screen.dart';

class PremiumUpgradeModal extends StatelessWidget {
  const PremiumUpgradeModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Icon(
            Icons.auto_graph_rounded,
            color: AppColors.primary,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'Boost Your Earnings!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Upgrade to Premium and unlock maximum mining power with 10x higher rewards.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          _buildRateComparison(),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PremiumUpgradeScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'UPGRADE NOW',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Maybe Later',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRateComparison() {
    return Row(
      children: [
        Expanded(
          child: _RateCard(
            label: 'Normal',
            rate: '0.01',
            unit: 'TAN/h',
            color: Colors.white12,
            icon: Icons.timer_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _RateCard(
            label: 'Premium',
            rate: '0.10',
            unit: 'TAN/h',
            color: AppColors.primary.withValues(alpha: 0.1),
            icon: Icons.bolt_rounded,
            isPremium: true,
          ),
        ),
      ],
    );
  }
}

class _RateCard extends StatelessWidget {
  final String label;
  final String rate;
  final String unit;
  final Color color;
  final IconData icon;
  final bool isPremium;

  const _RateCard({
    required this.label,
    required this.rate,
    required this.unit,
    required this.color,
    required this.icon,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPremium ? AppColors.primary : Colors.white10,
          width: isPremium ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isPremium ? AppColors.primary : AppColors.textSecondary,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isPremium ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                rate,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
