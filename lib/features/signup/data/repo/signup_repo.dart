import 'package:chat_app/features/signup/data/model/signup_request.dart';
import 'package:chat_app/features/signup/data/model/signup_response.dart';
import 'package:chat_app/features/signup/data/service/signup_service.dart';

class SignUpRepository {
  final SignUpService _service;

  SignUpRepository(this._service);

  Future<SignUpResponse> signUp(SignUpRequest request) async {
    return await _service.signUp(request);
  }
}
