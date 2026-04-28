import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tan_network/admin/admin_dashboard.dart';
import 'package:tan_network/admin/admin_users_list.dart';
import 'package:tan_network/admin/admin_withdrawals_list.dart';
import 'package:tan_network/theme/app_theme.dart';

final adminPageProvider = StateProvider<int>((ref) => 0);

class AdminLayout extends ConsumerStatefulWidget {
  const AdminLayout({super.key});

  @override
  ConsumerState<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends ConsumerState<AdminLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(adminPageProvider);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    final List<Widget> pages = [
      const AdminDashboard(),
      const AdminUsersList(),
      const AdminWithdrawalsList(),
    ];

    final List<Map<String, dynamic>> menuItems = [
      {'icon': Icons.dashboard_rounded, 'label': 'Dashboard'},
      {'icon': Icons.people_rounded, 'label': 'Users'},
      {'icon': Icons.account_balance_wallet_rounded, 'label': 'Withdrawals'},
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: isDesktop ? null : _buildSidebar(context, ref, currentIndex, menuItems),
      body: SafeArea(
        child: Row(
          children: [
            if (isDesktop) _buildSidebar(context, ref, currentIndex, menuItems),
            Expanded(
              child: Column(
                children: [
                  _buildHeader(context, !isDesktop),
                  Expanded(child: pages[currentIndex]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, WidgetRef ref, int currentIndex, List<Map<String, dynamic>> items) {
    return Container(
      width: 280,
      height: double.infinity,
      color: AppColors.card,
      child: Column(
        children: [
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary, size: 48),
          ),
          const SizedBox(height: 16),
          const Text(
            'TAN ADMIN',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 48),
          ...items.asMap().entries.map((entry) {
            return _sidebarItem(ref, entry.key, entry.value['icon'], entry.value['label'], currentIndex);
          }),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListTile(
              onTap: () => Navigator.of(context).pushReplacementNamed('/login'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: AppColors.error.withValues(alpha: 0.1),
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text(
                'Logout',
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _sidebarItem(WidgetRef ref, int index, IconData icon, String label, int current) {
    final isSelected = index == current;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: () {
          ref.read(adminPageProvider.notifier).state = index;
          if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
            Navigator.pop(context);
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        selected: isSelected,
        selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
        leading: Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool showMenu) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          if (showMenu)
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          if (showMenu) const SizedBox(width: 16),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              Text(
                'Admin Panel',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const Spacer(),
          const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person_rounded, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
