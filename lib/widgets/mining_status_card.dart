import 'package:flutter/material.dart';
import 'package:tan_network/theme/app_theme.dart';

class MiningStatusCard extends StatelessWidget {
  final bool isMining;
  final double hashRate;

  const MiningStatusCard({
    super.key,
    required this.isMining,
    required this.hashRate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isMining ? AppColors.primary : AppColors.error).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isMining ? Icons.bolt_rounded : Icons.pause_rounded,
              color: isMining ? AppColors.primary : AppColors.error,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMining ? 'Mining Active' : 'Mining Paused',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  isMining ? 'Current Rate: $hashRate MH/s' : 'Start mining to earn TAN',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          if (isMining)
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}
