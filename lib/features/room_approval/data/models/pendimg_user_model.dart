import 'package:chat_app/features/login/data/model/user_model.dart';

class PendingUserModel {
  final int roomId;
  final List<UserModel> users;

  PendingUserModel({
    required this.roomId,
    required this.users,
  });

  factory PendingUserModel.fromJson(Map<String, dynamic> json) {
    print("Parsing JSON: $json");
    return PendingUserModel(
      roomId: json['room_id'] is String 
          ? int.parse(json['room_id']) 
          : json['room_id'] ?? 0,
      users: (json['users'] as List<dynamic>?)
          ?.map((userJson) => UserModel.fromJson(userJson as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'users': users.map((user) => user.toJson()).toList(),
    };
  }
}