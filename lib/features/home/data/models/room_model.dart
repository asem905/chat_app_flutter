// ignore_for_file: non_constant_identifier_names

// class RoomModel {
//   final int id;
//   final String room_name;
//   final String? room_description;
//   final int unreadCount;
//   final DateTime createdAt;
//   final bool is_private;
//   final int room_created_by;
  
//   RoomModel({
//     required this.id,
//     required this.room_name,
//     required this.room_description,
//     required this.createdAt,
//     required this.is_private,
//     required this.room_created_by,
//     this.unreadCount=0
//   });

//   factory RoomModel.fromJson(Map<String, dynamic> json) {
//     return RoomModel(
//       id: json['id'],
//       room_name: json['room_name'],
//       room_description: json['room_description'],
//       unreadCount: json['unreadCount']??0,
//       createdAt: DateTime.parse(json['createdAt']),
//       is_private: json['is_private'],
//       room_created_by: json['room_created_by'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'room_name': room_name,
//       'room_description': room_description,
//       'unreadCount': unreadCount,
//       'createdAt': createdAt.toIso8601String(),
//       'is_private': is_private,
//       'room_created_by': room_created_by
//     };
//   }
// }
class RoomModel {
  final int id;
  final String room_name;
  final String? room_description;
  final int room_created_by;
  final bool is_private;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoomModel({
    required this.id,
    required this.room_name,
    this.room_description,
    required this.room_created_by,
    required this.is_private,
    this.unreadCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'],
      room_name: json['room_name'],
      room_description: json['room_description'],
      room_created_by: json['room_created_by'],
      is_private: json['is_private'] == 1 || json['is_private'] == true,
      unreadCount: json['unread_count'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_name': room_name,
      'room_description': room_description,
      'room_created_by': room_created_by,
      'is_private': is_private ? 1 : 0,
      'unread_count': unreadCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'last_synced_at': DateTime.now().toIso8601String(),
    };
  }
}