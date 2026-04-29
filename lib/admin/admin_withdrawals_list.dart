import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tan_network/theme/app_theme.dart';
import 'package:tan_network/providers/admin_provider.dart';
import 'package:tan_network/services/api_service.dart';
import 'package:intl/intl.dart';

class AdminWithdrawalsList extends ConsumerWidget {
  const AdminWithdrawalsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final withdrawalsAsync = ref.watch(pendingWithdrawalsProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return RefreshIndicator(
      onRefresh: () => ref.refresh(pendingWithdrawalsProvider.future),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pending Withdrawals',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: withdrawalsAsync.when(
                data: (list) {
                  if (list.isEmpty) {
                    return const Center(
                      child: Text(
                        'No pending withdrawals',
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }
                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        cardColor: AppColors.card,
                        dividerColor: Colors.white.withValues(alpha: 0.05),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingTextStyle: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            dataTextStyle: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                            ),
                            columns: const [
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('User')),
                              DataColumn(label: Text('Amount')),
                              DataColumn(label: Text('Network')),
                              DataColumn(label: Text('Action')),
                            ],
                            rows: list.map((w) {
                              final date = DateFormat(
                                'yyyy-MM-dd',
                              ).format(w.date);
                              final userEmail = (w.userId is Map)
                                  ? w.userId['email']
                                  : (w.userId?.toString() ?? 'Unknown');

                              return DataRow(
                                cells: [
                                  DataCell(Text(date)),
                                  DataCell(Text(userEmail)),
                                  DataCell(
                                    Text('${w.amount.toStringAsFixed(2)} TAN'),
                                  ),
                                  DataCell(Text(w.network)),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.check_circle_rounded,
                                            color: AppColors.primary,
                                          ),
                                          onPressed: () => _showApproveDialog(
                                            context,
                                            ref,
                                            w.id,
                                          ),
                                          tooltip: 'Approve',
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.cancel_rounded,
                                            color: AppColors.error,
                                          ),
                                          onPressed: () => _showActionDialog(
                                            context,
                                            ref,
                                            'Reject',
                                            w.id,
                                          ),
                                          tooltip: 'Reject',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Text(
                    'Error: $err',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showApproveDialog(BuildContext context, WidgetRef ref, String id) {
    final txController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text(
            'Approve Withdrawal',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter Transaction Hash (TXID) to complete this withdrawal:',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: txController,
                enabled: !isSubmitting,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: '0x...',
                  hintStyle: TextStyle(color: Colors.white24),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white10),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (txController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter TXID')),
                        );
                        return;
                      }

                      setState(() => isSubmitting = true);
                      try {
                        await ref
                            .read(apiServiceProvider)
                            .approveWithdrawal(id, txController.text.trim());

                        // Force refresh providers
                        ref.invalidate(pendingWithdrawalsProvider);
                        ref.invalidate(adminStatsProvider);

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Withdrawal approved successfully!',
                              ),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        }
                      } catch (e) {
                        setState(() => isSubmitting = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Text(
                      'Approve',
                      style: TextStyle(color: Colors.black),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionDialog(
    BuildContext context,
    WidgetRef ref,
    String action,
    String id,
  ) {
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(
            '$action Withdrawal',
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to $action this transaction?',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      setState(() => isSubmitting = true);
                      try {
                        if (action == 'Reject') {
                          await ref
                              .read(apiServiceProvider)
                              .rejectWithdrawal(id);
                        }

                        // Force refresh providers
                        ref.invalidate(pendingWithdrawalsProvider);
                        ref.invalidate(adminStatsProvider);

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Withdrawal ${action}ed successfully!',
                              ),
                              backgroundColor: action == 'Reject'
                                  ? AppColors.error
                                  : AppColors.primary,
                            ),
                          );
                        }
                      } catch (e) {
                        setState(() => isSubmitting = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(action, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
