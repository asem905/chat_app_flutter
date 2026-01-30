import 'dart:convert';
import 'package:chat_app/core/networking/api_constants.dart';
import 'package:chat_app/features/signup/data/model/signup_request.dart';
import 'package:chat_app/features/signup/data/model/signup_response.dart';
import 'package:http/http.dart' as http;

class SignUpService {
  // final Dio _dio;

  // LoginService(this._dio);

  Future<SignUpResponse> signUp(SignUpRequest request) async {
    var req = jsonEncode(request.toJson());
    print("SignUp request===========: $req");
    final response = await http.post(
      Uri.parse(ApiConstants.signUp),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: req,
    );
    print("SignUp response===========: ${response.body}");
    if (response.statusCode == 201) {
      var res = json.decode(response.body);
      return SignUpResponse.fromJson(res);
    } else {
      print("SignUp response===========: ${response.body}");
      throw Exception('Failed to SignUp');
    }
  }
}
