import 'package:chat_app/features/login/data/model/login_request.dart';
import 'package:chat_app/features/login/data/model/login_response.dart';
import 'package:chat_app/features/login/data/service/login_service.dart';
class LoginRepository {
  final LoginService _service;

  LoginRepository(this._service);

  Future<LoginResponse> login(LoginRequest request) async {
    return await _service.login(request);
  }
}