import 'package:chat_app/core/helpers/extensions.dart';
import 'package:chat_app/core/helpers/nav_helper.dart';
import 'package:chat_app/core/theming/app_colors.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ignore: non_constant_identifier_names
  int currnt_index = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items:NavBottomHelper.bottomNavItems(),
        currentIndex: currnt_index,
        onTap: (index) {
          setState(() {
            currnt_index = index;
            context.pushNamed(NavBottomHelper.navChoices()[index]);
          });
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const Center(
        child: Text('Settings Screen'),
      ),
    );
  }
}