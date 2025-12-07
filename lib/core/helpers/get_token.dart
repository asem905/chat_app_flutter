import 'package:chat_app/core/helpers/constants.dart';
import 'package:chat_app/core/helpers/shared_pref_helper.dart';

getTokenAndCurrentUserId() async {
    final token =
        await SharedPrefHelper.getSecuredString(SharedPrefKeys.userToken) ?? '';
    final currentUserId = await SharedPrefHelper.getInt('current_user_id');
    return {
      'token': token,
      'currentUserId': currentUserId,
    };
  }