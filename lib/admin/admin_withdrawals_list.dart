import 'package:flutter/material.dart';
import 'package:tan_network/theme/app_theme.dart';

class AdminWithdrawalsList extends StatelessWidget {
  const AdminWithdrawalsList({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
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
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
                      rows: List.generate(5, (index) {
                        return DataRow(cells: [
                          const DataCell(Text('2026-04-26')),
                          DataCell(Text('Taqiniazi $index')),
                          DataCell(Text('${500 + (index * 100)}.00 TAN')),
                          const DataCell(Text('BSC')),
                          DataCell(Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                                onPressed: () => _showActionDialog(context, 'Approve'),
                                tooltip: 'Approve',
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel_rounded, color: AppColors.error),
                                onPressed: () => _showActionDialog(context, 'Reject'),
                                tooltip: 'Reject',
                              ),
                            ],
                          )),
                        ]);
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showActionDialog(BuildContext context, String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('$action Withdrawal', style: const TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to $action this transaction?', style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: action == 'Approve' ? AppColors.primary : AppColors.error),
            child: Text(action, style: TextStyle(color: action == 'Approve' ? Colors.black : Colors.white)),
          ),
        ],
      ),
    );
  }
}
