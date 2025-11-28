class UserModel {
  String? username;
  String? email;
  String? id;
  String? token;
  String? status;
  String? role;
  String? avatar;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.token,
    required this.status,
    required this.role,
    required this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      token: json['token'] ?? '',
      status: json['status'] ?? '',
      role: json['role'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'token': token,
      'status': status,
      'role': role,
      'avatar': avatar
    };
  }
}