import 'dart:convert';

import 'package:crypto/crypto.dart';

class SendMessageRequest {
  final int roomId;
  final String content;
  final int? parentMessageId;
  final String idempotencyToken;
  
  SendMessageRequest({
    required this.roomId,
    required this.content,
    this.parentMessageId,
  }) : idempotencyToken = _generateToken(content, roomId);
  
  static String _generateToken(String content, int roomId) {
    // Generate deterministic token from content + room + timestamp
    final timestamp = DateTime.now().minute;
    final data = '$content-$roomId-$timestamp';
    return sha256.convert(utf8.encode(data)).toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'content': content,
      if (parentMessageId != null) 'parent_message_id': parentMessageId,
    };
  }
}