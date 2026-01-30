// ignore_for_file: non_constant_identifier_names

import 'package:chat_app/core/helpers/extensions.dart';
import 'package:chat_app/core/helpers/nav_helper.dart';
import 'package:chat_app/core/helpers/shared_pref_helper.dart';
import 'package:chat_app/core/services/token_manager_service.dart';
import 'package:chat_app/core/theming/app_colors.dart';
import 'package:chat_app/core/theming/text_styles.dart';
import 'package:chat_app/core/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int currnt_index = 1;
  String? userName;
  String? userEmail;
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await SharedPrefHelper.getString('user_name');
    print(name);
    final email = await SharedPrefHelper.getString('user_email');
    print(email);
    final id = await SharedPrefHelper.getInt('current_user_id');
    print(id);

    setState(() {
      userName = name ?? 'User';
      userEmail = email ?? 'user@example.com';
      userId = id;
    });
  }

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
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient
          SliverAppBar(
            expandedHeight: 200.h,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: ListView(
                    children: [
                      const SizedBox(height: 40),
                      // Profile Avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          backgroundColor: AppColors.primaryLight,
                          child: Text(
                            userName.toString()[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        userName ?? 'Loading...',
                        style: AppTextStyles.heading3.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail ?? '',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Profile Content
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 20),

              // Stats Cards
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.chat_bubble_outline,
                        label: 'Messages',
                        value: '0',
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.group_outlined,
                        label: 'Rooms',
                        value: '0',
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Account Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  'Account',
                  style: AppTextStyles.subtitle1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _buildMenuItem(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                subtitle: 'Update your personal information',
                onTap: () {
                  // Navigate to edit profile
                },
              ),

              _buildMenuItem(
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Update your password',
                onTap: () {
                  // Navigate to change password
                },
              ),

              const SizedBox(height: 24),

              // Preferences Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  'Preferences',
                  style: AppTextStyles.subtitle1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _buildMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Manage notification settings',
                onTap: () {
                  // Navigate to notifications settings
                },
              ),

              _buildMenuItem(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                subtitle: 'Toggle dark theme',
                trailing: Switch(
                  value: false,
                  onChanged: (value) {
                    // Toggle dark mode
                  },
                  activeColor: AppColors.primary,
                ),
              ),

              const SizedBox(height: 24),

              // About Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  'About',
                  style: AppTextStyles.subtitle1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _buildMenuItem(
                icon: Icons.info_outline,
                title: 'About App',
                subtitle: 'Version 1.0.0',
                onTap: () {
                  // Show about dialog
                },
              ),

              _buildMenuItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                onTap: () {
                  // Navigate to privacy policy
                },
              ),

              const SizedBox(height: 24),

              // Logout Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: ElevatedButton(
                  onPressed: () async {
                    await TokenManager().clearToken();
                    context.pushNamed(Routes.loginScreen);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout),
                      const SizedBox(width: 8),
                      Text('Logout', style: AppTextStyles.button),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(value, style: AppTextStyles.heading2.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4),
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
        trailing:
            trailing ??
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      ),
    );
  }
}
