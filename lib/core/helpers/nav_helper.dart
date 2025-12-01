import 'package:chat_app/core/routing/routes.dart';
import 'package:flutter/material.dart';

class NavBottomHelper {
  static List navChoices() {
    return [
      Routes.homeScreen,
      Routes.profileScreen,
      Routes.settingsScreen,
      Routes.discoverRoomsScreen,
    ];
  }

  static List<BottomNavigationBarItem> bottomNavItems() {
    return [
      BottomNavigationBarItem(icon: const Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: const Icon(Icons.person), label: 'Profile'),
      BottomNavigationBarItem(
        icon: const Icon(Icons.settings),
        label: 'Settings',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.family_restroom_rounded),
        label: 'Rooms',
      ),
    ];
  }
}
