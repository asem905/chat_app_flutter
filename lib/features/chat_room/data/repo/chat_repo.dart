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

  // ==================== GET MESSAGES ====================

  Future<List<MessageModel>> getMessages(
    int roomId, {
    int limit = 50,
    int offset = 0,
  }) async {
    // Always return cached data first
    final cachedMessages = await _getCachedMessages(roomId, limit, offset);
    // print('✅ Fetched cached messages 3: ${cachedMessages.length}');
    // If online, fetch fresh data and update cache
    if (_connectivityService.isOnline) {
      try {
        print('Fetching fresh messages...');
        final freshMessages = await _service.getMessages(
          roomId,
          limit: limit,
          offset: offset,
        );
        print('✅ Fetched fresh messages: ${freshMessages.length}');

        // Update cache
        await _updateCache(freshMessages);

        return freshMessages;
      } catch (e) {
        print('Failed to fetch fresh messages, using cache: $e');
        // Return cached data if network call fails
        return cachedMessages;
      }
    }

    // If offline, return cached data
    return cachedMessages;
  }

  Future<List<MessageModel>> _getCachedMessages(
    int roomId,
    int limit,
    int offset,
  ) async {
    print('Fetching messages from cache...');
    final cachedData = await _database.getMessages(
      roomId,
      limit: limit,
      offset: offset,
    );
    // print('✅ Fetched ${cachedData} messages from cache test 2');
    final userId = await getTokenAndCurrentUserId();
    final currentUserId = userId['currentUserId'];
    return cachedData.map((data) {
      return MessageModel.fromJson(data, currentUserId);
    }).toList();
  }

  Future<void> _updateCache(List<MessageModel> messages) async {
    if (messages.isEmpty) return;

    final messageMaps = messages.map((msg) => msg.toJson()).toList();
    print('Updating cache with ${messageMaps.length} messages');
    await _database.insertMessages(messageMaps);
  }

  // ==================== SEND MESSAGE ====================

  Future<MessageModel> sendMessage(
    int roomId,
    SendMessageRequest request,
  ) async {
    if (_connectivityService.isOnline) {
      try {
        // Try to send immediately
        final message = await _service.sendMessage(roomId, request);
        // Cache the sent message
        if(message.id == 0){
          print('✅ Message already sent from repo, skipping');
          return MessageModel(content: request.content, id: 0, createdAt: DateTime.now(), parentMessageId: request.parentMessageId, roomId: 0, userId: 0, isMine: 0);
        }
        await _database.insertMessage(message.toJson());

        return message;
      } catch (e) {
        if(e.toString().contains('409')){
          print('✅ Message already sent, skipping');
          throw Exception('Duplicate message2');
        }
        print('Failed to send message, adding to queue: $e');
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
    // Generate local ID for the message
    final localId = await _database.addPendingMessage(
      roomId: roomId,
      content: request.content,
      parentMessageId: request.parentMessageId,
    );
    final userId = await getTokenAndCurrentUserId();
    final currentUserId = userId['currentUserId'];
    // Create a temporary message to show in UI
    final tempMessage = MessageModel(
      id: 0, // Temporary ID
      roomId: roomId,
      userId: currentUserId,
      content: request.content,
      parentMessageId: request.parentMessageId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isMine: 1,
      isPending: 1, // Mark as pending
      localId: localId,
      username: '',
    );

    // Cache the pending message
    await _database.insertMessage({
      ...tempMessage.toJson(),
      'is_sent': 0, // Mark as not sent
      'local_id': localId,
    });

    return tempMessage;
  }

  // ==================== SYNC PENDING MESSAGES ====================

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

        // Try to send the message
        final sentMessage = await _service.sendMessage(
          pending['room_id'],
          request,
        );

        // Update cache with real message ID
        await _database.insertMessage({...sentMessage.toJson(), 'is_sent': 1});

        // Remove from pending queue
        await _database.removePendingMessage(pending['local_id']);

        print('✅ Synced pending message: ${pending['local_id']}');
      } catch (e) {
        print('❌ Failed to sync message: ${pending['local_id']}, error: $e');

        // Increment retry count
        await _database.incrementRetryCount(pending['local_id']);

        // Optional: Remove after too many retries (e.g., 5)
        final retryCount = pending['retry_count'] ?? 0;
        if (retryCount >= 5) {
          await _database.removePendingMessage(pending['local_id']);
          print('❌ Removed message after 5 failed retries');
        }
      }
    }
  }

  // ==================== DELETE MESSAGE ====================

  Future deleteMessage(int roomId, int messageId) async {
    // Delete from cache immediately
    await _database.deleteMessage(messageId);

    // If online, delete from server
    if (_connectivityService.isOnline) {
      try {
        await _service.deleteMessage(roomId, messageId);
      } catch (e) {
        throw Exception(e.toString());
      }
    }
  }

  // ==================== UTILITY ====================

  Future<void> clearCache(int roomId) async {
    await _database.clearRoomMessages(roomId);
  }
  // ==================== Edit Message ====================

  Future<MessageModel> editMessage(int roomId, int messageId, String content) async {
    if (_connectivityService.isOnline) {
      try {
        // Try to send immediately
        final message = await _service.editMessage(roomId, messageId, content);
        await _database.updateMessage(message.toJson());

        return message;
      } catch (e) {
        print('Failed to send message, adding to queue: $e');
        // If sending fails, queue it
        return await _queueMessage(roomId, SendMessageRequest(roomId: roomId,content: content, parentMessageId: 0));
      }
    } else {
      // If offline, queue the message
      return await _queueMessage(roomId, SendMessageRequest(roomId: roomId,content: content, parentMessageId: 0));
    }
  }
}
