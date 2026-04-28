import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tan_network/providers/auth_provider.dart';
import 'package:tan_network/theme/app_theme.dart';
import 'package:tan_network/widgets/logout_button.dart';

import 'package:image_picker/image_picker.dart';
import 'package:tan_network/models/user_model.dart';
import 'package:tan_network/services/api_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        setState(() => _isUploading = true);
        final apiService = ref.read(apiServiceProvider);
        await apiService.uploadProfileImage(image.path);
        
        // Refresh profile to get updated image
        await ref.read(authProvider.notifier).fetchProfile();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showUpdatePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text('Update Password', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                if (oldPasswordController.text.isEmpty || newPasswordController.text.isEmpty) return;
                
                setDialogState(() => isLoading = true);
                try {
                  await ref.read(apiServiceProvider).updatePassword(
                    oldPasswordController.text,
                    newPasswordController.text,
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password updated successfully!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                    );
                  }
                } finally {
                  setDialogState(() => isLoading = false);
                }
              },
              child: isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('UPDATE'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, user),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
              child: Column(
                children: [
                  _buildStatGrid(user),
                  const SizedBox(height: 24),
                  _buildAccountSection(user),
                  const SizedBox(height: 24),
                  _buildReferralCard(context, user),
                  const SizedBox(height: 24),
                  _buildSecuritySection(),
                  const SizedBox(height: 48),
                  _buildLogoutButton(context, ref),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, UserModel user) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.background,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withValues(alpha: 0.2),
                AppColors.background,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Stack(
                children: [
                  GestureDetector(
                    onTap: _isUploading ? null : _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.card,
                            backgroundImage: user.profileImage != null 
                              ? NetworkImage('${ref.read(apiServiceProvider).baseUrl.replaceAll('/api', '')}${user.profileImage}')
                              : null,
                            child: user.profileImage == null 
                              ? Text(
                                  user.name[0].toUpperCase(),
                                  style: const TextStyle(fontSize: 40, color: AppColors.primary, fontWeight: FontWeight.bold),
                                )
                              : null,
                          ),
                          if (_isUploading)
                            const CircularProgressIndicator(color: AppColors.primary),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, size: 16, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (user.isPremium)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.star_rounded, size: 20, color: Colors.black),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                user.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
      actions: [const AppLogoutButton(), const SizedBox(width: 8)],
    );
  }

  Widget _buildStatGrid(UserModel user) {
    return Row(
      children: [
        Expanded(
          child: _statItem('Mining Rate', '${user.miningRate}', 'TAN/h', Icons.bolt_rounded, AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statItem('Status', user.isPremium ? 'Premium' : 'Standard', 'Account', Icons.verified_user_rounded, AppColors.accent),
        ),
      ],
    );
  }

  Widget _statItem(String label, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 16),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(width: 4),
              Text(unit, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _infoRow(Icons.public_rounded, 'Country', user.country ?? 'Not Provided'),
          const Divider(height: 40, color: Colors.white10),
          _infoRow(Icons.location_city_rounded, 'City', user.city ?? 'Not Provided'),
          const Divider(height: 40, color: Colors.white10),
          _infoRow(Icons.security_rounded, 'Account ID', '#${user.id.substring(user.id.length - 8)}'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Security', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          ListTile(
            onTap: _showUpdatePasswordDialog,
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.accent),
            ),
            title: const Text('Change Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text('Update your login credentials', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCard(BuildContext context, UserModel user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.accent.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.card_giftcard_rounded, color: AppColors.primary),
              SizedBox(width: 12),
              Text('Your Referral Code', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  user.referralCode.isNotEmpty ? user.referralCode.toUpperCase() : 'NOT SET',
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold, 
                    letterSpacing: 2, 
                    color: user.referralCode.isNotEmpty ? AppColors.primary : Colors.grey,
                  ),
                ),
                IconButton(
                  onPressed: user.referralCode.isNotEmpty ? () {
                    // Copy to clipboard logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Referral code copied!')),
                    );
                  } : null,
                  icon: Icon(Icons.copy_rounded, color: user.referralCode.isNotEmpty ? Colors.white70 : Colors.white24, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () {
        ref.read(authProvider.notifier).logout();
        Navigator.of(context).pushReplacementNamed('/login');
      },
      icon: const Icon(Icons.logout_rounded, size: 20, color: Colors.white),
      label: const Text('LOGOUT ACCOUNT', style: TextStyle(letterSpacing: 1.2, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.error.withValues(alpha: 0.8),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
