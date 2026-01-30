class SignUpResponse {
  final String status;
  final Map<String, dynamic> data;

  SignUpResponse({required this.status, required this.data});

  factory SignUpResponse.fromJson(Map<String, dynamic> json) {
    return SignUpResponse(status: json['status'], data: json['data']);
  }
}
