class LoginResponse {
  final String status;
  final Map<String, dynamic> data;

  LoginResponse({
    required this.status,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'],
      data: json['data'],
    );
  }
}