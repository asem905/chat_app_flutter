import 'package:chat_app/core/routing/app_router.dart';
import 'package:chat_app/core/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatApp extends StatelessWidget {
  final AppRouter appRouter;
  final bool isLoggedInUser;
  final GlobalKey<NavigatorState> navigatorKey;
  
  const ChatApp({
    super.key,
    required this.appRouter,
    required this.navigatorKey,
    this.isLoggedInUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      designSize: const Size(375, 812),
      child: MaterialApp(
        navigatorKey: navigatorKey, // Important for navigation from anywhere
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
        ),
        onGenerateRoute: appRouter.generateRoute,
        initialRoute: isLoggedInUser ? Routes.homeScreen : Routes.loginScreen,
      ),
    );
  }
}