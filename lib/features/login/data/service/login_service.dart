import 'dart:convert';

import 'package:chat_app/core/networking/api_constants.dart';
import 'package:chat_app/features/login/data/model/login_request.dart';
import 'package:chat_app/features/login/data/model/login_response.dart';
import 'package:http/http.dart' as http;
class LoginService {
  // final Dio _dio;
  
  // LoginService(this._dio);

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      body: request.toJson(),
    );
    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      if(res['status'] == 'SUCCESS'){}
      return LoginResponse.fromJson(res);
    } else {
      throw Exception('Failed to login');
    }
  }
}