import 'package:chat_app/core/database/chat_database.dart';
import 'package:chat_app/core/helpers/get_token.dart';
import 'package:chat_app/core/services/internet_connectivity_service.dart';
import 'package:chat_app/features/chat_room/data/model/message_model.dart';
import 'package:chat_app/features/chat_room/data/model/send_message_request.dart';
import 'package:chat_app/features/chat_room/data/service/chat_service.dart';

class ChatRepositoryWithCache {
  final ChatRoomService _service;
  final ChatDatabase _database;
  final ConnectivityService _connectivityService;

  ChatRepositoryWithCache({
    required ChatRoomService service,
    required ChatDatabase database,
    required ConnectivityService connectivityService,
  }) : _service = service,
       _database = database,
       _connectivityService = connectivityService;

  Future<List<MessageModel>> getMessages(
    int roomId, {
    int limit = 200,
    int offset = 0,
  }) async {
    final cachedMessages = await _getCachedMessages(roomId);
    if (_connectivityService.isOnline) {
      try {
        final freshMessages = await _service.getMessages(
          roomId,
          limit: limit,
          offset: offset,
        );
        await _updateCache(freshMessages);
        return freshMessages;
      } catch (e) {
        return cachedMessages;
      }
    }
    return cachedMessages;
  }

  Future<List<MessageModel>> _getCachedMessages(int roomId) async {
    final cachedData = await _database.getMessages(roomId);
    final userId = await getTokenAndCurrentUserId();
    final currentUserId = userId['currentUserId'];
    return cachedData.map((data) {
      return MessageModel.fromJson(data, currentUserId);
    }).toList();
  }

  Future<void> _updateCache(List<MessageModel> messages) async {
    if (messages.isEmpty) return;

    final messagesToCache = messages.where((m) => m.id > 0).toList();

    if (messagesToCache.isEmpty) {
      return;
    }

    final messageMaps = messagesToCache.map((msg) => msg.toJson()).toList();

    try {
      await _database.insertMessages(messageMaps);
    } catch (e) {
      print('Failed to cache messages: $e');
    }
  }

  Future<void> cacheMessage(MessageModel message) async {
    if (message.id <= 0) {
      return;
    }

    try {
      await _database.insertMessage(message.toJson());
    } catch (e) {
      print('Failed to cache message: $e');
    }
  }

  Future<MessageModel> sendMessage(
    int roomId,
    SendMessageRequest request,
  ) async {
    if (_connectivityService.isOnline) {
      try {
        final message = await _service.sendMessage(roomId, request);
        if (message.id == 0) {
          return MessageModel(
            content: request.content,
            id: 0,
            createdAt: DateTime.now(),
            parentMessageId: request.parentMessageId,
            roomId: 0,
            userId: 0,
            isMine: 0,
          );
        }
        await _database.insertMessage(message.toJson());

        return message;
      } catch (e) {
        if (e.toString().contains('409')) {
          throw Exception('Duplicate message2');
        }
        // If sending fails, queue it
        return await _queueMessage(roomId, request);
      }
    } else {
      // If offline, queue the message
      return await _queueMessage(roomId, request);
    }
  }

  Future<MessageModel> _queueMessage(
    int roomId,
    SendMessageRequest request,
  ) async {
    final localId = await _database.addPendingMessage(
      roomId: roomId,
      content: request.content,
      parentMessageId: request.parentMessageId,
    );
    final userId = await getTokenAndCurrentUserId();
    final currentUserId = userId['currentUserId'];
    final tempMessage = MessageModel(
      id: 0,
      roomId: roomId,
      userId: currentUserId,
      content: request.content,
      parentMessageId: request.parentMessageId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isMine: 1,
      isPending: 1,
      localId: localId,
      username: '',
    );
    await _database.insertMessage({
      ...tempMessage.toJson(),
      'is_sent': 0,
      'local_id': localId,
    });

    return tempMessage;
  }

  Future<void> syncPendingMessages() async {
    if (!_connectivityService.isOnline) return;

    final pendingMessages = await _database.getPendingMessages();

    for (var pending in pendingMessages) {
      try {
        final request = SendMessageRequest(
          roomId: pending['room_id'],
          content: pending['content'],
          parentMessageId: pending['parent_message_id'],
        );

        final sentMessage = await _service.sendMessage(
          pending['room_id'],
          request,
        );

        await _database.insertMessage({...sentMessage.toJson(), 'is_sent': 1});

        await _database.removePendingMessage(pending['local_id']);
      } catch (e) {
        await _database.incrementRetryCount(pending['local_id']);
        final retryCount = pending['retry_count'] ?? 0;
        if (retryCount >= 5) {
          await _database.removePendingMessage(pending['local_id']);
        }
      }
    }
  }

  Future deleteMessage(int roomId, int messageId) async {
    await _database.deleteMessage(messageId);

    if (_connectivityService.isOnline) {
      try {
        await _service.deleteMessage(roomId, messageId);
      } catch (e) {
        throw Exception(e.toString());
      }
    }
  }

  Future<void> clearCache(int roomId) async {
    await _database.clearRoomMessages(roomId);
  }

  Future<MessageModel> editMessage(
    int roomId,
    int messageId,
    String content,
  ) async {
    if (_connectivityService.isOnline) {
      try {
        final message = await _service.editMessage(roomId, messageId, content);
        await _database.updateMessage(message.toJson());

        return message;
      } catch (e) {
        return await _queueMessage(
          roomId,
          SendMessageRequest(
            roomId: roomId,
            content: content,
            parentMessageId: 0,
          ),
        );
      }
    } else {
      return await _queueMessage(
        roomId,
        SendMessageRequest(
          roomId: roomId,
          content: content,
          parentMessageId: 0,
        ),
      );
    }
  }
}
