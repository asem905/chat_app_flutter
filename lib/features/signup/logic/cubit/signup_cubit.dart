import 'package:chat_app/core/helpers/shared_pref_helper.dart';
import 'package:chat_app/core/services/token_manager_service.dart';
import 'package:chat_app/features/signup/data/model/signup_request.dart';
import 'package:chat_app/features/signup/data/repo/signup_repo.dart';
import 'package:chat_app/features/signup/logic/cubit/signup_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final SignUpRepository _repository;

  SignUpCubit(this._repository) : super(SignUpInitial());

  Future<void> signUp(
    String email,
    String password,
    String username,
    String confirmPassword,
    String role,
  ) async {
    emit(SignUpLoading());

    try {
      final request = SignUpRequest(
        email: email,
        password: password,
        username: username,
        confirmPassword: confirmPassword,
        role: role,
      );
      final response = await _repository.signUp(request);

      final token = response.data['user']['token'];
      final userId = response.data['user']['id'] as int;
      final userName = response.data['user']['username'];

      await SharedPrefHelper.setData('current_user_id', userId);
      await SharedPrefHelper.setData('user_name', userName);

      await TokenManager().saveToken(token, validity: const Duration(hours: 1));

      emit(SignUpSuccess(response));
    } catch (e) {
      emit(SignUpError(e.toString()));
    }
  }

  void resetState() {
    emit(SignUpInitial());
  }
}
