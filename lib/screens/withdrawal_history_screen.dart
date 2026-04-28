import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tan_network/models/withdrawal_model.dart';
import 'package:tan_network/providers/withdrawal_provider.dart';
import 'package:tan_network/theme/app_theme.dart';

class WithdrawalHistoryScreen extends ConsumerWidget {
  const WithdrawalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(withdrawalHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('WITHDRAWAL HISTORY')),
      body: historyAsync.when(
        data: (history) => history.isEmpty
            ? const Center(child: Text('No history found'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  return _buildHistoryItem(item);
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildHistoryItem(WithdrawalModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          _getStatusIcon(item.status),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.amount.toStringAsFixed(2)} TAN',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Network: ${item.network} | ${item.date.day}/${item.date.month}/${item.date.year}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          _getStatusChip(item.status),
        ],
      ),
    );
  }

  Widget _getStatusIcon(WithdrawalStatus status) {
    IconData icon;
    Color color;
    switch (status) {
      case WithdrawalStatus.completed:
        icon = Icons.check_circle_outline;
        color = AppColors.primary;
        break;
      case WithdrawalStatus.pending:
        icon = Icons.access_time;
        color = AppColors.accent;
        break;
      case WithdrawalStatus.rejected:
        icon = Icons.error_outline;
        color = AppColors.error;
        break;
    }
    return Icon(icon, color: color, size: 28);
  }

  Widget _getStatusChip(WithdrawalStatus status) {
    Color color;
    switch (status) {
      case WithdrawalStatus.completed: color = AppColors.primary; break;
      case WithdrawalStatus.pending: color = AppColors.accent; break;
      case WithdrawalStatus.rejected: color = AppColors.error; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
