class UserModel {
  int? id;
  String? username;
  String? email;
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
      id: _parseId(json['id']),
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      token: json['token'] ?? '',
      status: json['status'] ?? '',
      role: json['role'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }

  // Helper method to safely parse id from both String and int
  static int? _parseId(dynamic id) {
    if (id == null) return null;
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    return null;
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