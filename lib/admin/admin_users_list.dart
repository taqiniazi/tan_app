import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tan_network/theme/app_theme.dart';
import 'package:tan_network/services/api_service.dart';
import 'package:tan_network/models/user_model.dart';

class AdminUsersList extends ConsumerStatefulWidget {
  const AdminUsersList({super.key});

  @override
  ConsumerState<AdminUsersList> createState() => _AdminUsersListState();
}

class _AdminUsersListState extends ConsumerState<AdminUsersList> {
  bool _isLoading = true;
  List<UserModel> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await ref.read(apiServiceProvider).getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: _fetchUsers,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh List'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _users.isEmpty
                    ? const Center(child: Text('No users found', style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          return Card(
                            color: AppColors.card,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Colors.white10),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                                child: Text(
                                  user.name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(user.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(user.email, style: const TextStyle(color: Colors.white70)),
                                  const SizedBox(height: 4),
                                  Text('Mining Rate: ${user.miningRate}x', style: const TextStyle(color: AppColors.primary)),
                                ],
                              ),
                              trailing: _statusChip(user.role == 'admin' ? 'Admin' : 'User'),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = status == 'Admin' ? Colors.purpleAccent : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
