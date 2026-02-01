import 'package:chat_app/chat_app.dart';
import 'package:chat_app/core/di/dependency_incjection.dart.dart';
import 'package:chat_app/core/routing/app_router.dart';
import 'package:chat_app/core/routing/routes.dart';
import 'package:chat_app/core/services/token_manager_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//we made global navigator key to be able to navigate from anywhere in the app
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool isLoggedInUser = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setUpGetIt();
  await ScreenUtil.ensureScreenSize();
  // Initialize token manager with logout callback
  TokenManager().initialize(() {
    // Navigate to login when token expires
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      Routes.loginScreen,
      (route) => false,
    );
  });

  isLoggedInUser = await checkIfLoggedInUser();

  runApp(
    ChatApp(
      appRouter: AppRouter(),
      isLoggedInUser: isLoggedInUser,
      navigatorKey: navigatorKey,
    ),
  );
}

Future<bool> checkIfLoggedInUser() async {
  final isValid = await TokenManager().checkAndRestoreToken();

  if (isValid) {
    return true;
  } else {
    return false;
  }
}
