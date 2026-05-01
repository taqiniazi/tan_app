import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tan_network/providers/mining_provider.dart';
import 'package:tan_network/providers/auth_provider.dart';
import 'package:tan_network/theme/app_theme.dart';
import 'package:tan_network/widgets/mining_progress_bar.dart';
import 'package:tan_network/widgets/logout_button.dart';
import 'package:tan_network/widgets/premium_banner.dart';

class MiningScreen extends ConsumerWidget {
  const MiningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final miningState = ref.watch(miningProvider);
    final user = ref.watch(authProvider).user;
    final bool isBanned = user?.isFlagged ?? false;

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
                progress:
                    (24 * 3600 - miningState.remainingTime.inSeconds) /
                    (24 * 3600),
              ),
              const SizedBox(height: 32),
            ],
            if (isBanned)
              _buildBannedMessage()
            else ...[
              _buildActionCard(context, miningState, ref),
              if (!(user?.isPremium ?? false)) ...[
                const SizedBox(height: 32),
                const PremiumUpgradeBanner(),
              ],
            ],
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
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.05),
      ),
      child: isMining
          ? const _MiningPulseAnimation()
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

  Widget _buildActionCard(
    BuildContext context,
    MiningState state,
    WidgetRef ref,
  ) {
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
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
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
            onPressed: state.isMining
                ? null
                : () async {
                    try {
                      if (state.canClaim) {
                        await ref.read(miningProvider.notifier).claimReward();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Rewards claimed successfully!'),
                            ),
                          );
                        }
                      } else {
                        await ref.read(miningProvider.notifier).startMining();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Mining session started!'),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: state.isMining
                  ? Colors.grey.withValues(alpha: 0.2)
                  : (state.canClaim ? AppColors.accent : AppColors.primary),
              disabledBackgroundColor: Colors.grey.withValues(alpha: 0.1),
              minimumSize: const Size(double.infinity, 60),
            ),
            child: Text(
              state.isMining
                  ? 'MINING IN PROGRESS'
                  : (state.canClaim ? 'CLAIM REWARDS' : 'START MINING'),
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

  Widget _buildBannedMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: const Column(
        children: [
          Icon(Icons.gavel_rounded, color: AppColors.error, size: 48),
          SizedBox(height: 16),
          Text(
            'ACCOUNT BANNED',
            style: TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Your account has been flagged for suspicious activity and is currently restricted.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textPrimary),
          ),
          SizedBox(height: 16),
          Text(
            'For more information, please email us with your username at:',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          Text(
            'support@tannetwork.online',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
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

class _MiningPulseAnimation extends StatefulWidget {
  const _MiningPulseAnimation();

  @override
  State<_MiningPulseAnimation> createState() => _MiningPulseAnimationState();
}

class _MiningPulseAnimationState extends State<_MiningPulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _glowAnimation = Tween<double>(
      begin: 0.1,
      end: 0.6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(
                    alpha: _glowAnimation.value,
                  ),
                  blurRadius: 40 * _scaleAnimation.value,
                  spreadRadius: 10 * _scaleAnimation.value,
                ),
              ],
            ),
            child: const Icon(
              Icons.bolt_rounded,
              size: 80,
              color: AppColors.primary,
            ),
          ),
        );
      },
    );
  }
}
