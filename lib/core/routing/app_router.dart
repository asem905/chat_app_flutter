import 'package:chat_app/core/di/dependency_incjection.dart.dart';
import 'package:chat_app/core/routing/routes.dart';
import 'package:chat_app/features/home/logic/cubit/home_cubit.dart';
import 'package:chat_app/features/home/view/home_screen.dart';
import 'package:chat_app/features/login/logic/cubit/login_cubit.dart';
import 'package:chat_app/features/login/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    final arguments = settings.arguments;
    print("Generating route for ${settings.name} with arguments: $arguments");
    switch (settings.name) {
      case Routes.loginScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<LoginCubit>(),
            child: const LoginScreen()
            ));
      case Routes.homeScreen:
        return MaterialPageRoute(builder: (_) => BlocProvider(
          create: (context) => getIt<HomeCubit>(),
          child: const HomeScreen(),
        ));
      default:
        return null;
    }
  }
}