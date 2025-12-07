import 'package:chat_app/core/helpers/constants.dart';
import 'package:chat_app/core/helpers/shared_pref_helper.dart';
import 'package:chat_app/features/login/data/model/login_request.dart';
import 'package:chat_app/features/login/data/repo/login_repo.dart';
import 'package:chat_app/features/login/logic/cubit/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class LoginCubit extends Cubit<LoginState> {
  final LoginRepository _repository;

  LoginCubit(this._repository) : super(LoginInitial());

  Future<void> login(String email, String password) async {
    emit(LoginLoading());
    
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _repository.login(request);
      print("token+=+: ${response.data['user']['token']}");
      await saveUserToken(response.data['user']['token']);
      print("user id: ${response.data['user']['id']}");
      await SharedPrefHelper.setData('current_user_id', response.data['user']['id'] as int);
      emit(LoginSuccess(response));
    } catch (e) {
      print("================="+e.toString());
      emit(LoginError(e.toString()));
    }
  }

  void resetState() {
    emit(LoginInitial());
  }
  Future<void> saveUserToken(String token) async {
    //clear sharedpref first:
    await SharedPrefHelper.clearAllSecuredData();
    print("================================================");
    await SharedPrefHelper.setSecuredString(SharedPrefKeys.userToken, token);
    print("================================================");
  }
}