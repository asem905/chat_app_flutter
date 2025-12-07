class MessageModel {
  final int id;
  final String? username;
  final int roomId;
  final int userId;
  final String content;
  final int? parentMessageId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int isMine;
  final int isPending; // ✅ NEW: Is message pending upload?
  final String? localId; // ✅ NEW: Local temporary ID
  final int isDeleted;
  final int isEdited;

  MessageModel({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.content,
    this.parentMessageId,
    required this.createdAt,
    this.updatedAt,
    required this.isMine,
    this.username,
    this.isPending = 0, // ✅ NEW
    this.localId, // ✅ NEW
    this.isDeleted = 0,
    this.isEdited = 0,
  });

  // Update toJson and fromJson accordingly
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'user_id': userId,
      'content': content,
      'parent_message_id': parentMessageId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_sent': isPending==1 ? 0 : 1,
      'local_id': localId,
      'username': username ?? '',
      'is_deleted': isDeleted,
      'is_edited': isEdited,
      'is_pending': isPending,
    };
  }

  // In MessageModel.dart

  factory MessageModel.fromJson(Map<String, dynamic> json, int currentUserId) {
    // Helper function for safe String access
    String safeString(String key) {
      return (json[key] as String?) ?? '';
    }
    // print('json: $json');
    // print('json[id]: ${json['id'] as int?}');
    // print('json[room_id]: ${json['room_id'] as int?}');
    // print('json[user_id]: ${json['user_id'] as int?}');
    // print('json[content]: ${json['content'] as String?}');
    // print('json[parent_message_id]: ${json['parent_message_id']}');
    // print('json[created_at]: ${json['created_at']}');
    // print('json[updated_at]: ${DateTime.parse(json['updated_at']??json['created_at'])}');
    // print('json[is_sent]: ${json['is_sent'] as int?}');
    // print('json[local_id]: ${json['local_id'] as String?}');
    // print('json[username]: ${json['username'] as String?}');
    // print('json[is_deleted]: ${json['is_deleted'] }');
    // print('json[is_edited]: ${json['is_edited'] }');
    // print('json[is_pending]: ${json['is_pending']}');
    // print('json[isMine]: ${json['user_id'] == currentUserId? 1:0}');
    if(json['is_deleted'] == null) json['is_deleted'] = 0;
    if(json['is_edited'] == null) json['is_edited'] = 0;
    if(json['is_pending'] == null) json['is_pending'] = 0;
    return MessageModel(
      id: json['id'] ?? 0,
      roomId: json['room_id'] is int? json['room_id'] : int.parse(json['room_id'].toString())  , 
      userId: json['user_id'], 
      content: (json['content'] as String?) ?? '',
      parentMessageId: json['parent_message_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']??json['created_at']),
      isMine: json['user_id'] == currentUserId? 1:0,
      username: safeString('username'),
      isPending: json['is_pending'] as int,
      localId: safeString('local_id'),
      isDeleted: (json['is_deleted'] as int == 1)? 1:0,
      isEdited: (json['is_edited'] as int == 1)? 1:0,
    );
  }
}
