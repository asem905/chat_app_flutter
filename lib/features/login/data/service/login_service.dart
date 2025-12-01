import 'dart:convert';

import 'package:chat_app/core/networking/api_constants.dart';
import 'package:chat_app/features/login/data/model/login_request.dart';
import 'package:chat_app/features/login/data/model/login_response.dart';
import 'package:http/http.dart' as http;
class LoginService {
  // final Dio _dio;
  
  // LoginService(this._dio);

  Future<LoginResponse> login(LoginRequest request) async {
    var req=jsonEncode(request.toJson());
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: req
    );
    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      return LoginResponse.fromJson(res);
    } else {
      print(response.body);
      throw Exception('Failed to login');
    }
  }
}