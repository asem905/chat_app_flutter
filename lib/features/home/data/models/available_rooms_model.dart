// available_rooms_response_model.dart
// ignore_for_file: non_constant_identifier_names

import 'package:chat_app/features/login/data/model/user_model.dart';

class AvailableRoomsResponseModel {
  final String status;
  final List<RoomWithMembersModel> availableRooms;

  AvailableRoomsResponseModel({
    required this.status,
    required this.availableRooms,
  });

  factory AvailableRoomsResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final roomsJson = data['usersRooms'] as List<dynamic>? ?? [];

    return AvailableRoomsResponseModel(
      status: json['status'] ?? 'ERROR',
      availableRooms: roomsJson
          .map((e) => RoomWithMembersModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': {
        'usersRooms': availableRooms.map((e) => e.toJson()).toList(),
      },
    };
  }
}


class RoomWithMembersModel {
  final int room_id;
  final String room_name;
  final String? room_description;
  final bool is_private;
  final int room_created_by;
  final DateTime? room_created_at;
  final String room_owner;
  final List<UserModel> members; // List of members

  RoomWithMembersModel({
    required this.room_id,
    required this.room_name,
    required this.room_description,
    required this.is_private,
    required this.room_created_by,
    required this.members,
    required this.room_owner,
    this.room_created_at,
  });

  factory RoomWithMembersModel.fromJson(Map<String, dynamic> json) {
    return RoomWithMembersModel(
      room_owner: json['room_owner'] ?? '',
      room_id: json['room_id'] ?? 0,
      room_name: json['room_name'] ?? '',
      room_description: json['room_description'],
      is_private: json['is_private'] ?? false,
      room_created_by: json['room_created_by'] ?? 0,
      room_created_at: json['room_created_at'] != null ? DateTime.parse(json['room_created_at']) : null,
      members: (json['members'] as List<dynamic>?)
              ?.map((e) => UserModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_id': room_id,
      'room_name': room_name,
      'room_description': room_description,
      'is_private': is_private,
      'room_created_by': room_created_by,
      'room_created_at': room_created_at?.toIso8601String(),
      'room_owner': room_owner,
      'members': members.map((e) => e.toJson()).toList(),
    };
  }
}