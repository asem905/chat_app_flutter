

import 'package:chat_app/features/home/data/repos/home_repo.dart';
import 'package:chat_app/features/home/data/services/home_service.dart';
import 'package:chat_app/features/home/logic/cubit/home_cubit.dart';
import 'package:chat_app/features/login/data/repo/login_repo.dart';
import 'package:chat_app/features/login/data/service/login_service.dart';
import 'package:chat_app/features/login/logic/cubit/login_cubit.dart';
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
  getIt.registerLazySingleton<HomeService>(()=>HomeService());
  getIt.registerLazySingleton<HomeRepository>(()=>HomeRepository(getIt()));
  getIt.registerFactory<HomeCubit>(()=>HomeCubit(getIt())); 
}