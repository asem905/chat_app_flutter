import 'package:chat_app/core/database/chat_database.dart';
import 'package:chat_app/core/networking/web_socket_service.dart';
import 'package:chat_app/core/services/internet_connectivity_service.dart';
import 'package:chat_app/features/chat_room/data/repo/chat_repo.dart';
import 'package:chat_app/features/chat_room/data/service/chat_service.dart';
import 'package:chat_app/features/chat_room/logic/cubit/chat_cubit.dart';
import 'package:chat_app/features/home/data/repos/discover_rooms_repo.dart';
import 'package:chat_app/features/home/data/repos/home_repo.dart';
import 'package:chat_app/features/home/data/services/discover_rooms_service.dart';
import 'package:chat_app/features/home/data/services/home_service.dart';
import 'package:chat_app/features/home/logic/cubit/discover_rooms_cubit.dart';
import 'package:chat_app/features/home/logic/cubit/home_cubit.dart';
import 'package:chat_app/features/login/data/repo/login_repo.dart';
import 'package:chat_app/features/login/data/service/login_service.dart';
import 'package:chat_app/features/login/logic/cubit/login_cubit.dart';
import 'package:chat_app/features/room_approval/data/repos/room_approval_repo.dart';
import 'package:chat_app/features/room_approval/data/service/room_approval_service.dart';
import 'package:chat_app/features/signup/data/repo/signup_repo.dart';
import 'package:chat_app/features/signup/data/service/signup_service.dart';
import 'package:chat_app/features/signup/logic/cubit/signup_cubit.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;
setUpGetIt() async {
  final connectivityService = ConnectivityService();
  final database = ChatDatabase.instance;

  // Register connectivity service as singleton
  getIt.registerLazySingleton<ConnectivityService>(() => connectivityService);
  //login dependencies
  getIt.registerLazySingleton<LoginService>(() => LoginService());
  getIt.registerLazySingleton<LoginRepository>(() => LoginRepository(getIt()));
  getIt.registerFactory<LoginCubit>(() => LoginCubit(getIt()));

  // Signup dependencies
  getIt.registerLazySingleton<SignUpService>(() => SignUpService());
  getIt.registerLazySingleton<SignUpRepository>(
    () => SignUpRepository(getIt()),
  );
  getIt.registerFactory<SignUpCubit>(() => SignUpCubit(getIt()));

  //Home dependencies
  getIt.registerLazySingleton<HomeService>(() => HomeService());
  getIt.registerLazySingleton<HomeRepositoryWithCache>(
    () => HomeRepositoryWithCache(
      service: getIt<HomeService>(),
      database: database,
      connectivityService: getIt<ConnectivityService>(),
    ),
  );
  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(getIt(), getIt<ConnectivityService>()),
  );

  // discover rooms dependencies
  getIt.registerLazySingleton<DiscoverRoomsService>(
    () => DiscoverRoomsService(),
  );
  getIt.registerLazySingleton<DiscoverRoomsRepository>(
    () => DiscoverRoomsRepository(getIt(), getIt<ConnectivityService>()),
  );
  getIt.registerFactory<DiscoverRoomsCubit>(
    () => DiscoverRoomsCubit(getIt(), getIt<ConnectivityService>()),
  );

  //room approval dependencies
  getIt.registerLazySingleton<RoomApprovalService>(() => RoomApprovalService());
  getIt.registerLazySingleton<RoomApprovalRepository>(
    () => RoomApprovalRepository(getIt(), getIt<ConnectivityService>()),
  );
  // RoomApprovalCubit is created directly in the router with roomId parameter

  //chat room dependencies
  final webSocketService = WebSocketService();
  webSocketService.connect();

  getIt.registerLazySingleton<WebSocketService>(() => webSocketService);
  getIt.registerLazySingleton<ChatRoomService>(() => ChatRoomService());
  getIt.registerLazySingleton<ChatRepositoryWithCache>(
    () => ChatRepositoryWithCache(
      service: getIt<ChatRoomService>(),
      database: database,
      connectivityService: getIt<ConnectivityService>(),
    ),
  );
  getIt.registerFactory<ChatRoomCubit>(
    () => ChatRoomCubit(
      getIt<ChatRepositoryWithCache>(),
      getIt<WebSocketService>(),
      getIt<ConnectivityService>(),
    ),
  );
}
