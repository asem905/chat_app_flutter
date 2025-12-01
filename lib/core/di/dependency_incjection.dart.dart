

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

final getIt=GetIt.instance;
setUpGetIt()async{
  //login dependencies
  getIt.registerLazySingleton<LoginService>(()=>LoginService());
  getIt.registerLazySingleton<LoginRepository>(()=>LoginRepository(getIt()));
  getIt.registerFactory<LoginCubit>(()=>LoginCubit(getIt()));
  
  //Signup dependencies
  // getIt.registerLazySingleton<SignUpApiService>(()=>SignUpApiService(dio));
  // getIt.registerLazySingleton<SignupRepo>(()=>SignupRepo(getIt()));
  // getIt.registerFactory<SignUpCubit>(()=>SignUpCubit(getIt()));

  //Home dependencies
  final homeService = await HomeService.create();
  getIt.registerSingleton<HomeService>(homeService);
  getIt.registerLazySingleton<HomeRepository>(()=>HomeRepository(getIt()));
  getIt.registerFactory<HomeCubit>(()=>HomeCubit(getIt())); 

  // discover rooms dependencies
  final discoverRoomsService = await DiscoverRoomsService.create();
  getIt.registerLazySingleton<DiscoverRoomsService>(()=>discoverRoomsService);
  getIt.registerLazySingleton<DiscoverRoomsRepository>(()=>DiscoverRoomsRepository(getIt()));
  getIt.registerFactory<DiscoverRoomsCubit>(()=>DiscoverRoomsCubit(getIt()));

  //room approval dependencies
  final roomApprovalService = await RoomApprovalService.create();
  getIt.registerLazySingleton<RoomApprovalService>(()=>roomApprovalService);
  getIt.registerLazySingleton<RoomApprovalRepository>(()=>RoomApprovalRepository(getIt()));
  getIt.registerFactory<RoomApprovalCubit>(()=>RoomApprovalCubit(getIt()));

}