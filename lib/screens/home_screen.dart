import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tan_network/providers/balance_provider.dart';
import 'package:tan_network/theme/app_theme.dart';
import 'package:tan_network/widgets/balance_card.dart';
import 'package:tan_network/widgets/mining_status_card.dart';
import 'package:tan_network/widgets/premium_banner.dart';
import 'package:tan_network/screens/withdrawal_history_screen.dart';
import 'package:tan_network/widgets/animations.dart';
import 'package:tan_network/providers/auth_provider.dart';
import 'package:tan_network/providers/activity_provider.dart';
import 'package:tan_network/providers/mining_provider.dart';
import 'package:intl/intl.dart';
import 'package:tan_network/widgets/logout_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(balanceProvider);
    final user = ref.watch(authProvider).user;
    final activityAsync = ref.watch(activityProvider);
    final miningState = ref.watch(miningProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DASHBOARD'),
        actions: [
          const AppLogoutButton(),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            FadeSlideTransition(
              duration: const Duration(milliseconds: 400),
              child: Text(
                'Good morning, ${user?.name ?? "User"}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
            FadeSlideTransition(
              duration: const Duration(milliseconds: 600),
              child: BalanceCard(balance: balance),
            ),
            const SizedBox(height: 24),
            FadeSlideTransition(
              duration: const Duration(milliseconds: 700),
              child: _buildQuickActions(context),
            ),
            const SizedBox(height: 24),
            FadeSlideTransition(
              duration: const Duration(milliseconds: 800),
              child: MiningStatusCard(
                isMining: miningState.isMining,
                hashRate: miningState.isMining ? 48.2 : 0.0,
              ),
            ),
            const SizedBox(height: 24),
            const FadeSlideTransition(
              duration: Duration(milliseconds: 900),
              child: PremiumUpgradeBanner(),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('Recent Activity', ref),
            const SizedBox(height: 16),
            activityAsync.when(
              data: (activities) {
                if (activities.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('No recent activity', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  );
                }
                return Column(
                  children: activities.take(5).map((activity) {
                    final type = activity['type'] as String;
                    final amount = activity['amount'] as num;
                    final date = DateTime.parse(activity['createdAt']);
                    
                    IconData icon;
                    Color color;
                    String title;
                    
                    switch (type) {
                      case 'mining':
                        icon = Icons.trending_up;
                        color = AppColors.primary;
                        title = 'Mining Reward';
                        break;
                      case 'referral':
                        icon = Icons.people_alt_outlined;
                        color = AppColors.accent;
                        title = 'Referral Bonus';
                        break;
                      case 'withdrawal':
                        icon = Icons.outbound_rounded;
                        color = Colors.redAccent;
                        title = 'Withdrawal';
                        break;
                      default:
                        icon = Icons.account_balance_wallet_outlined;
                        color = Colors.blue;
                        title = 'Transaction';
                    }

                    return FadeSlideTransition(
                      duration: const Duration(milliseconds: 600),
                      child: _buildActivityItem(
                        title,
                        '${type == 'withdrawal' ? '-' : '+'}${amount.toStringAsFixed(2)} TAN',
                        _formatDate(date),
                        icon,
                        color,
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AnimatedTap(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Withdrawal feature is currently under maintenance.'),
                  backgroundColor: AppColors.accent,
                ),
              );
            },
            child: Opacity(
              opacity: 0.5,
              child: _actionButton(
                context,
                'Withdraw',
                Icons.outbound_rounded,
                AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AnimatedTap(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WithdrawalHistoryScreen())),
            child: _actionButton(
              context,
              'History',
              Icons.history_rounded,
              AppColors.accent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButton(BuildContext context, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () => ref.invalidate(activityProvider),
          child: const Text('Refresh', style: TextStyle(color: AppColors.primary)),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  Widget _buildActivityItem(
    String title,
    String value,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
