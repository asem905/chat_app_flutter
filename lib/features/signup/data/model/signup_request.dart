class SignUpRequest {
  final String email;
  final String password;
  final String username;
  final String confirmPassword;
  final String role;

  SignUpRequest({
    required this.email,
    required this.password,
    required this.username,
    required this.confirmPassword,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'username': username,
      'confirmPassword': confirmPassword,
      'role': role,
    };
  }
}
