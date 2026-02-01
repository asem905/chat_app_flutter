import 'package:chat_app/core/helpers/shared_pref_helper.dart';
import 'package:chat_app/core/services/token_manager_service.dart';
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
      print("Login request: ${request.toJson()}");
      final response = await _repository.login(request);

      final token = response.data['user']['token'];
      final userId = response.data['user']['id'] as int;
      final userName = response.data['user']['username'];

      // Save user data
      await SharedPrefHelper.setData('current_user_id', userId);
      await SharedPrefHelper.setData('user_name', userName);

      // Save token with expiration handling
      await TokenManager().saveToken(token, validity: const Duration(days: 3));

      emit(LoginSuccess(response));
    } catch (e) {
      print("Login error: ${e.toString()}");
      emit(LoginError(e.toString()));
    }
  }

  void resetState() {
    emit(LoginInitial());
  }
}
