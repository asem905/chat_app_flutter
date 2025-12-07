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
import 'package:chat_app/features/room_approval/logic/cubit/room_approval_cubit.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;
setUpGetIt() async {
  final connectivityService=ConnectivityService();
  final database=ChatDatabase.instance;
  //login dependencies
  getIt.registerLazySingleton<LoginService>(() => LoginService());
  getIt.registerLazySingleton<LoginRepository>(() => LoginRepository(getIt()));
  getIt.registerFactory<LoginCubit>(() => LoginCubit(getIt()));

  //Signup dependencies
  // getIt.registerLazySingleton<SignUpApiService>(()=>SignUpApiService(dio));
  // getIt.registerLazySingleton<SignupRepo>(()=>SignupRepo(getIt()));
  // getIt.registerFactory<SignUpCubit>(()=>SignUpCubit(getIt()));

  //Home dependencies
  getIt.registerLazySingleton<HomeService>(() => HomeService());
  getIt.registerLazySingleton<HomeRepositoryWithCache>(() => HomeRepositoryWithCache(service: getIt<HomeService>(),database: database,connectivityService: connectivityService));
  getIt.registerFactory<HomeCubit>(() => HomeCubit(getIt(),connectivityService));

  // discover rooms dependencies
  getIt.registerLazySingleton<DiscoverRoomsService>(
    () => DiscoverRoomsService(),
  );
  getIt.registerLazySingleton<DiscoverRoomsRepository>(
    () => DiscoverRoomsRepository(getIt()),
  );
  getIt.registerFactory<DiscoverRoomsCubit>(() => DiscoverRoomsCubit(getIt()));

  //room approval dependencies
  getIt.registerLazySingleton<RoomApprovalService>(() => RoomApprovalService());
  getIt.registerLazySingleton<RoomApprovalRepository>(
    () => RoomApprovalRepository(getIt()),
  );
  getIt.registerFactory<RoomApprovalCubit>(() => RoomApprovalCubit(getIt()));

  //chat room dependencies
  final webSocketService = WebSocketService();
  webSocketService.connect();
  
  getIt.registerLazySingleton<WebSocketService>(() => webSocketService);
  getIt.registerLazySingleton<ChatRoomService>(() => ChatRoomService());
  getIt.registerLazySingleton<ChatRepositoryWithCache>(
    () => ChatRepositoryWithCache(service: getIt<ChatRoomService>(), database: database, connectivityService: connectivityService),
  );
  getIt.registerFactory<ChatRoomCubit>(
    () => ChatRoomCubit(getIt<ChatRepositoryWithCache>(), getIt<WebSocketService>(), connectivityService),
  );
}
