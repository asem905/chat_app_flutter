import 'package:chat_app/core/di/dependency_incjection.dart.dart';
import 'package:chat_app/core/routing/routes.dart';
import 'package:chat_app/features/additional_screens/profile_screen.dart';
import 'package:chat_app/features/additional_screens/settings_screen.dart';
import 'package:chat_app/features/chat_room/logic/cubit/chat_cubit.dart';
import 'package:chat_app/features/chat_room/view/chat_room_screen.dart';
import 'package:chat_app/features/home/logic/cubit/discover_rooms_cubit.dart';
import 'package:chat_app/features/home/logic/cubit/home_cubit.dart';
import 'package:chat_app/features/home/view/discover_rooms_screen.dart';
import 'package:chat_app/features/home/view/home_screen.dart';
import 'package:chat_app/features/login/logic/cubit/login_cubit.dart';
import 'package:chat_app/features/login/view/login_screen.dart';
import 'package:chat_app/features/room_approval/logic/cubit/room_approval_cubit.dart';
import 'package:chat_app/features/room_approval/view/room_approval_screen.dart';
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
      case Routes.discoverRoomsScreen:
        return MaterialPageRoute(builder: (_) => BlocProvider(
          create: (context) => getIt<DiscoverRoomsCubit>(),
          child: const DiscoverRoomsScreen(),
        ));
      case Routes.settingsScreen:
        return MaterialPageRoute(builder: (_) => SettingsScreen());
      case Routes.profileScreen:
        return MaterialPageRoute(builder: (_) => ProfileScreen());
      case Routes.roomApprovalScreen:
        return MaterialPageRoute(builder: (_) => BlocProvider(
          create: (context) => getIt<RoomApprovalCubit>(),
          child: RoomApprovalScreen(roomId: (arguments! as List)[0],roomName: (arguments as List)[1],),
        ));
      case Routes.chatRoomScreen:
        return MaterialPageRoute(builder: (_)=>BlocProvider(
          create: (context) => getIt<ChatRoomCubit>(),
          child: ChatRoomScreen(roomId: (arguments! as List)[0], roomName: (arguments as List)[1], currentUserId: arguments[2]),
        ));
      default:
        return null;
    }
  }
}