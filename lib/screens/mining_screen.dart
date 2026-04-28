import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:tan_network/providers/mining_provider.dart';
import 'package:tan_network/theme/app_theme.dart';
import 'package:tan_network/widgets/mining_progress_bar.dart';
import 'package:tan_network/widgets/logout_button.dart';

class MiningScreen extends ConsumerWidget {
  const MiningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final miningState = ref.watch(miningProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CLOUD MINING'),
        actions: [const AppLogoutButton(), const SizedBox(width: 8)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            _buildMiningAnimation(miningState.isMining),
            const SizedBox(height: 40),
            _buildMiningInfo(context, miningState),
            const SizedBox(height: 32),
            if (miningState.isMining) ...[
              MiningProgressBar(
                progress: (24 * 3600 - miningState.remainingTime.inSeconds) / (24 * 3600),
              ),
              const SizedBox(height: 32),
            ],
            _buildActionCard(context, miningState, ref),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMiningAnimation(bool isMining) {
    return Container(
      height: 250,
      width: 250,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.05),
        boxShadow: isMining
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 50,
                  spreadRadius: 10,
                )
              ]
            : [],
      ),
      child: isMining
          ? Lottie.network(
              'https://lottie.host/813d10c2-7f97-4f67-88d4-5396556e8071/S0rGfP6X3g.json', // Stable network pulse animation
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.bolt_rounded,
                    size: 80,
                    color: AppColors.primary,
                  ),
                );
              },
            )
          : const Icon(
              Icons.sensors_off_rounded,
              size: 100,
              color: AppColors.textSecondary,
            ),
    );
  }

  Widget _buildMiningInfo(BuildContext context, MiningState state) {
    return Column(
      children: [
        Text(
          state.isMining ? 'SYSTEM ACTIVE' : 'SYSTEM IDLE',
          style: TextStyle(
            color: state.isMining ? AppColors.primary : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.speed, color: AppColors.accent, size: 20),
            const SizedBox(width: 8),
            Text(
              'Rate: ${state.miningRate} TAN/hr',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, MiningState state, WidgetRef ref) {
    final String timerText = _formatDuration(state.remainingTime);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: AppTheme.cryptoCardDecoration(
        glowOpacity: state.isMining ? 0.05 : 0,
      ),
      child: Column(
        children: [
          if (state.isMining) ...[
            const Text(
              'NEXT ACTIVATION IN',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              timerText,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ] else ...[
            const Text(
              'READY TO MINE',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start your 24-hour mining session now.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: state.isMining ? null : () => ref.read(miningProvider.notifier).startMining(),
            style: ElevatedButton.styleFrom(
              backgroundColor: state.isMining ? Colors.grey.withValues(alpha: 0.2) : AppColors.primary,
              disabledBackgroundColor: Colors.grey.withValues(alpha: 0.1),
              minimumSize: const Size(double.infinity, 60),
            ),
            child: Text(
              state.isMining ? 'MINING IN PROGRESS' : 'START MINING',
              style: TextStyle(
                color: state.isMining ? AppColors.textSecondary : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
