import 'dart:convert';
import 'package:chat_app/core/helpers/get_token.dart';
import 'package:chat_app/core/networking/api_constants.dart';
import 'package:chat_app/features/chat_room/data/model/message_model.dart';
import 'package:chat_app/features/chat_room/data/model/send_message_request.dart';
import 'package:http/http.dart' as http;

class ChatRoomService {
  ChatRoomService();

  Future<List<MessageModel>> getMessages(
    int roomId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final result = await getTokenAndCurrentUserId();
    final token = result['token'];
    final currentUserId = await result['currentUserId'];
    final response = await http.get(
      Uri.parse("${ApiConstants.rooms}/$roomId/messages"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print('response.body: ${response.body}');
    try {
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> messagesJson = responseData['data'] ?? [];
        print('messagesJson: $messagesJson');
        return messagesJson
            .map((json) => MessageModel.fromJson(json, currentUserId))
            .toList();
      } else {
        throw Exception('Failed to fetch messages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching messages: ${e.toString()}');
      throw Exception('Failed to fetch messages: ${e.toString()}');
    }
  }

  Future<MessageModel> sendMessage(
    int roomId,
    SendMessageRequest request,
  ) async {
    print('roomId: $roomId, request: ${request.content} and parentMessageId: ${request.parentMessageId} and roomId: ${request.roomId}');
    final result = await getTokenAndCurrentUserId();
    final token = result['token'];
    final currentUserId = await result['currentUserId'];
    final response = await http.post(
      Uri.parse("${ApiConstants.rooms}/$roomId/messages"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'idempotency-token': request.idempotencyToken
      },
      body: jsonEncode(request.toJson()),
    );
    print('response.statusCode: ${response.statusCode}');
    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final messageJson = responseData['data'];
        return MessageModel.fromJson(messageJson, currentUserId);
      } else {
        if(response.statusCode == 409) {
          print('✅ Message already sent, skipping');
          return MessageModel(content: request.content, id: 0, createdAt: DateTime.now(), parentMessageId: request.parentMessageId, roomId: 0, userId: 0, isMine: 0);
        }else{
          throw Exception('Failed to send message: ${response.statusCode}');
        }
        
      }
    } catch (e) {
      if(e.toString().contains('409')) {
        print('✅ Message already sent, skipping');
        return MessageModel(content: request.content, id: 0, createdAt: DateTime.now(), parentMessageId: request.parentMessageId, roomId: 0, userId: 0, isMine: 0);
      }else{
        print('Error sending message: ${e.toString()}');
        throw Exception('Failed to send message: ${e.toString()}');
      }
    }
  }

  Future<MessageModel> editMessage(
    int roomId,
    int messageId,
    String content,
  ) async {
    final result = await getTokenAndCurrentUserId();
    final token = result['token'];
    final currentUserId = await result['currentUserId'];
    final response = await http.put(
      Uri.parse("${ApiConstants.rooms}/$roomId/messages/$messageId"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'content': content}),
    );

    try {
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final messageJson = responseData['data'];
        return MessageModel.fromJson(messageJson, currentUserId);
      } else {
        throw Exception('Failed to edit message: ${response.statusCode}');
      }
    } catch (e) {
      print('Error editing message: ${e.toString()}');
      throw Exception('Failed to edit message: ${e.toString()}');
    }
  }

  Future<void> deleteMessage(int roomId, int messageId) async {
    final result = await getTokenAndCurrentUserId();
    final token = result['token'];
    final response = await http.delete(
      Uri.parse("${ApiConstants.rooms}/$roomId/messages/$messageId"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    try {
      if (response.statusCode == 200) {
        // Success - no return needed
        print('Message $messageId deleted successfully');
      } else {
        throw Exception('Failed to delete message: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting message: ${e.toString()}');
      throw Exception('Failed to delete message: ${e.toString()}');
    }
  }
}
