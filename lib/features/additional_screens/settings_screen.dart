import 'package:chat_app/core/helpers/extensions.dart';
import 'package:chat_app/core/helpers/nav_helper.dart';
import 'package:chat_app/core/theming/app_colors.dart';
import 'package:chat_app/core/theming/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ignore: non_constant_identifier_names
  int currnt_index = 2;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: BottomNavigationBar(
        items: NavBottomHelper.bottomNavItems(),
        currentIndex: currnt_index,
        onTap: (index) {
          setState(() {
            currnt_index = index;
            context.pushNamed(NavBottomHelper.navChoices()[index]);
          });
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.surface,
        elevation: 8,
      ),
      appBar: AppBar(
        title: Text('Settings', style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        children: [
          // Notifications Section
          _buildSectionHeader('Notifications'),
          _buildSwitchTile(
            icon: Icons.notifications_outlined,
            title: 'Push Notifications',
            subtitle: 'Receive push notifications',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
          ),
          _buildSwitchTile(
            icon: Icons.volume_up_outlined,
            title: 'Sound',
            subtitle: 'Play sound for notifications',
            value: _soundEnabled,
            onChanged: (value) {
              setState(() => _soundEnabled = value);
            },
          ),

          const SizedBox(height: 16),

          // Appearance Section
          _buildSectionHeader('Appearance'),
          _buildSwitchTile(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            subtitle: 'Use dark theme',
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() => _darkModeEnabled = value);
              // TODO: Implement dark mode toggle
            },
          ),
          _buildSettingTile(
            icon: Icons.text_fields_outlined,
            title: 'Font Size',
            subtitle: 'Medium',
            onTap: () {
              // Show font size picker
            },
          ),

          const SizedBox(height: 16),

          // Chat Settings Section
          _buildSectionHeader('Chat'),
          _buildSettingTile(
            icon: Icons.wallpaper_outlined,
            title: 'Chat Wallpaper',
            subtitle: 'Change chat background',
            onTap: () {
              // Navigate to wallpaper picker
            },
          ),
          _buildSettingTile(
            icon: Icons.backup_outlined,
            title: 'Backup Chats',
            subtitle: 'Backup your chat history',
            onTap: () {
              // Navigate to backup settings
            },
          ),

          const SizedBox(height: 16),

          // Privacy & Security Section
          _buildSectionHeader('Privacy & Security'),
          _buildSettingTile(
            icon: Icons.lock_outline,
            title: 'Privacy',
            subtitle: 'Manage your privacy settings',
            onTap: () {
              // Navigate to privacy settings
            },
          ),
          _buildSettingTile(
            icon: Icons.security_outlined,
            title: 'Security',
            subtitle: 'Two-factor authentication, etc.',
            onTap: () {
              // Navigate to security settings
            },
          ),
          _buildSettingTile(
            icon: Icons.block_outlined,
            title: 'Blocked Users',
            subtitle: 'Manage blocked users',
            onTap: () {
              // Navigate to blocked users
            },
          ),

          const SizedBox(height: 16),

          // Storage Section
          _buildSectionHeader('Storage'),
          _buildSettingTile(
            icon: Icons.storage_outlined,
            title: 'Storage Usage',
            subtitle: 'Manage app storage',
            onTap: () {
              // Navigate to storage settings
            },
          ),
          _buildSettingTile(
            icon: Icons.delete_outline,
            title: 'Clear Cache',
            subtitle: 'Free up space',
            onTap: () {
              _showClearCacheDialog();
            },
          ),

          const SizedBox(height: 16),

          // About Section
          _buildSectionHeader('About'),
          _buildSettingTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () {
              // Navigate to help
            },
          ),
          _buildSettingTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'Version 1.0.0',
            onTap: () {
              _showAboutDialog();
            },
          ),
          _buildSettingTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            onTap: () {
              // Navigate to privacy policy
            },
          ),
          _buildSettingTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'Read our terms of service',
            onTap: () {
              // Navigate to terms
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Text(
        title,
        style: AppTextStyles.subtitle1.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryVeryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle, style: AppTextStyles.caption),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryVeryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle, style: AppTextStyles.caption),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'Are you sure you want to clear the cache? This will free up space but may slow down the app temporarily.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Chat App'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Version: 1.0.0'),
            const SizedBox(height: 8),
            const Text('A modern chat application built with Flutter.'),
            const SizedBox(height: 16),
            Text(
              '© 2024 Chat App. All rights reserved.',
              style: AppTextStyles.caption,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
