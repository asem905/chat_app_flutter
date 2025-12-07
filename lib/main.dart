import 'package:chat_app/chat_app.dart';
import 'package:chat_app/core/di/dependency_incjection.dart.dart';
import 'package:chat_app/core/helpers/constants.dart';
import 'package:chat_app/core/helpers/extensions.dart';
import 'package:chat_app/core/helpers/shared_pref_helper.dart';
import 'package:chat_app/core/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

bool isLoggedInUser = false;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setUpGetIt();
  await ScreenUtil.ensureScreenSize();
  await checkIfLoggedInUser();
  runApp(ChatApp(appRouter: AppRouter(),isLoggedInUser: isLoggedInUser)); 
}

checkIfLoggedInUser() async {
  String token = await SharedPrefHelper.getSecuredString(
    SharedPrefKeys.userToken,
  );
  print("token: $token");
  if (!token.isNullOrEmpty()) {
    isLoggedInUser = true;
  } else {
    isLoggedInUser = false;
  }
}
