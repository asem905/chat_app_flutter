class SendMessageRequest {
  final int roomId;
  final String content;
  final int? parentMessageId;

  SendMessageRequest({
    required this.roomId,
    required this.content,
    this.parentMessageId,
  });

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'content': content,
      if (parentMessageId != null) 'parent_message_id': parentMessageId,
    };
  }
}