import 'dart:async';
import 'package:chat_app/core/networking/web_socket_service.dart';
import 'package:chat_app/core/services/internet_connectivity_service.dart';
import 'package:chat_app/features/chat_room/data/model/message_model.dart';
import 'package:chat_app/features/chat_room/data/model/send_message_request.dart';
import 'package:chat_app/features/chat_room/data/repo/chat_repo.dart';
import 'package:chat_app/features/chat_room/logic/cubit/chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatRoomCubit extends Cubit<ChatRoomState> {
  final ChatRepositoryWithCache _repository;
  final WebSocketService _webSocketService;
  final ConnectivityService _connectivityService;

  int _currentPage = 1;
  static const int _pageSize = 50;
  int? _currentRoomId;
  int? _currentUserId; // ✅ NEW: Store current user ID

  StreamSubscription<MessageModel>? _messageSubscription;
  StreamSubscription<bool>? _connectionSubscription;
  StreamSubscription<Map<String, dynamic>>? _typingSubscription;

  Timer? _typingDebounceTimer;
  Timer? _typingStopTimer;
  DateTime? _lastTypingEmit;

  ChatRoomCubit(
    this._repository,
    this._webSocketService,
    this._connectivityService,
  ) : super(ChatRoomInitial()) {
    _initWebSocketListeners();
    _initConnectivityListener();
  }

  void _initWebSocketListeners() {
    _messageSubscription = _webSocketService.onNewMessage.listen((message) {
      _handleNewMessage(message);
    });

    _typingSubscription = _webSocketService.onTyping.listen((data) {
      _handleTypingEvent(data);
    });
  }

  void _initConnectivityListener() {
    _connectionSubscription = _connectivityService.onConnectivityChanged.listen(
      (isOnline) {
        if (isOnline) {
          print('🌐 Back online! Syncing pending messages...');
          _syncPendingMessages();
          // Rejoin room if needed
          if (_currentRoomId != null) {
            _webSocketService.joinRoom(_currentRoomId!);
          }
        } else {
          print('📵 Gone offline. Messages will be queued.');
        }
      },
    );
  }

  Future<void> _syncPendingMessages() async {
    try {
      await _repository.syncPendingMessages();

      // Refresh messages after sync
      if (_currentRoomId != null) {
        await loadMessages(_currentRoomId!, refresh: true);
      }
    } catch (e) {
      print('Error syncing pending messages: $e');
    }
  }

  void _handleNewMessage(MessageModel message) {
    final currentState = state;
    if (currentState is ChatRoomLoaded) {
      if (message.roomId == _currentRoomId) {
        // Check for duplicates
        final messageExists = currentState.messages.any(
          (m) => m.id == message.id,
        );
        if (!messageExists) {
          // Remove pending message if this is the synced version
          final updatedMessages = currentState.messages
              .where((m) => m.localId != message.localId || m.id == message.id)
              .toList();

          emit(
            ChatRoomLoaded(
              messages: [message, ...updatedMessages],
              hasMore: currentState.hasMore,
              currentPage: currentState.currentPage,
              isOffline: !_connectivityService.isOnline,
              typingUsers: currentState.typingUsers,
            ),
          );
        }
      }
    }
  }

  void _handleTypingEvent(Map<String, dynamic> data) {
    final currentState = state;
    if (currentState is! ChatRoomLoaded) return;

    final userId = data['userId'] as int?;
    final username = data['username'] as String?;
    final isTyping = data['isTyping'] as bool? ?? true;

    print(
      '📝 Typing event received: userId=$userId, username=$username, isTyping=$isTyping, currentUserId=$_currentUserId',
    );

    if (userId == null) return;

    // ✅ Don't show typing indicator for current user
    if (userId == _currentUserId) {
      print('⏭️ Ignoring typing event for current user');
      return;
    }

    final updatedTypingUsers = Map<int, String>.from(currentState.typingUsers);

    if (isTyping && username != null) {
      updatedTypingUsers[userId] = username;
      print('✅ Added typing user: $username (userId: $userId)');
    } else {
      updatedTypingUsers.remove(userId);
      print('❌ Removed typing user: $username (userId: $userId)');
    }

    print('👥 Current typing users: ${updatedTypingUsers.values.join(", ")}');

    emit(
      ChatRoomLoaded(
        messages: currentState.messages,
        hasMore: currentState.hasMore,
        currentPage: currentState.currentPage,
        isOffline: currentState.isOffline,
        typingUsers: updatedTypingUsers,
      ),
    );
  }

  Future<void> loadMessages(
    int roomId, {
    bool refresh = false,
    int? currentUserId,
  }) async {
    if (refresh) {
      _currentPage = 1;
      emit(ChatRoomLoading());
    }

    _currentRoomId = roomId;
    if (currentUserId != null) {
      _currentUserId = currentUserId; // ✅ Store current user ID
    }

    if (_connectivityService.isOnline) {
      _webSocketService.joinRoom(roomId);
    }

    try {
      // This will return cached data if offline, or fresh data if online
      final messages = await _repository.getMessages(
        roomId,
        limit: _pageSize,
        offset: 0,
      );
      print('✅ Successfully Fetched messages: ${messages.length}');
      emit(
        ChatRoomLoaded(
          messages: messages,
          hasMore: messages.length >= _pageSize,
          currentPage: _currentPage,
          isOffline: !_connectivityService.isOnline,
        ),
      );
    } catch (e) {
      emit(ChatRoomError(e.toString()));
    }
  }

  Future<void> loadMoreMessages(int roomId) async {
    final currentState = state;
    if (currentState is! ChatRoomLoaded) return;
    if (!currentState.hasMore) return;

    emit(ChatRoomLoadingMore(currentState.messages));

    try {
      final newMessages = await _repository.getMessages(
        roomId,
        limit: _pageSize,
        offset: currentState.messages.length,
      );

      _currentPage++;

      emit(
        ChatRoomLoaded(
          messages: [...currentState.messages, ...newMessages],
          hasMore: newMessages.length >= _pageSize,
          currentPage: _currentPage,
          isOffline: !_connectivityService.isOnline,
        ),
      );
    } catch (e) {
      emit(currentState);
    }
  }

  Future<void> editMessage(int roomId, int messageId, String content) async {
    try {
      final currentState = state;
      var message = await _repository.editMessage(roomId, messageId, content);
      print('==================Successfully edited message: $message');
      if (currentState is ChatRoomLoaded) {
        emit(
          ChatRoomLoaded(
            messages: currentState.messages
                .map((m) => m.id == message.id ? message : m)
                .toList(),
            hasMore: currentState.hasMore,
            currentPage: currentState.currentPage,
            isOffline: !_connectivityService.isOnline,
          ),
        );
      }

      // Show toast if offline
      if (!_connectivityService.isOnline) {
        emit(MessageQueued('Message will be automatically edited when online'));
        if (currentState is ChatRoomLoaded) {
          emit(currentState);
        }
      }
    } catch (e) {
      print('Error editing message: $e');
    }
  }

  Future<void> sendMessage(
    int roomId,
    String content, {
    int? parentMessageId,
  }) async {
    if (content.trim().isEmpty) return;

    final currentState = state;

    try {
      final request = SendMessageRequest(
        roomId: roomId,
        content: content.trim(),
        parentMessageId: parentMessageId,
      );

      // This will either send or queue the message
      final message = await _repository.sendMessage(roomId, request);
      if (message.id == 0) {
        print('✅ Message already sent from cubit, skipping');
        return;
      }
      // Add message to UI immediately (even if pending)
      if (currentState is ChatRoomLoaded) {
        emit(
          ChatRoomLoaded(
            messages: [...currentState.messages, message],
            hasMore: currentState.hasMore,
            currentPage: currentState.currentPage,
            isOffline: !_connectivityService.isOnline,
          ),
        );
      }

      // Show toast if offline
      if (!_connectivityService.isOnline) {
        emit(MessageQueued('Message will be sent when online'));
        if (currentState is ChatRoomLoaded) {
          emit(currentState);
        }
      }
    } catch (e) {
      if (e.toString().contains('409')) {
        print('✅ Message already sent, skipping');
        emit(DuplicateMessage('Message already sent'));
      }
      if (currentState is ChatRoomLoaded) {
        emit(currentState);
      }
      emit(MessageSendError(e.toString()));
    }
  }

  Future<void> deleteMessage(int roomId, int messageId) async {
    final currentState = state;

    try {
      await _repository.deleteMessage(roomId, messageId);

      if (currentState is ChatRoomLoaded) {
        final updatedMessages = currentState.messages
            .where((m) => m.id != messageId)
            .toList();

        emit(
          ChatRoomLoaded(
            messages: updatedMessages,
            hasMore: currentState.hasMore,
            currentPage: currentState.currentPage,
            isOffline: !_connectivityService.isOnline,
          ),
        );
      }
    } catch (e) {
      if (currentState is ChatRoomLoaded) {
        emit(currentState);
      }
      print('Error deleting message from cubit: $e');
      emit(ChatRoomError(e.toString().split(':')[2]));
    }
  }

  void leaveRoom() {
    if (_currentRoomId != null) {
      _webSocketService.leaveRoom(_currentRoomId!);
      _webSocketService.emitStopTyping(_currentRoomId!);
      _currentRoomId = null;
    }
  }

  void startTyping(int roomId, String username) {
    if (!_connectivityService.isOnline) return;

    final now = DateTime.now();
    // Debounce: only emit once every 2 seconds
    if (_lastTypingEmit != null &&
        now.difference(_lastTypingEmit!).inSeconds < 2) {
      return;
    }
    print(
      'user(in start typing function) $username is typing in room of id $roomId',
    );
    _webSocketService.emitTyping(roomId, username);
    _lastTypingEmit = now;

    // Auto-stop after 3 seconds of inactivity
    _typingStopTimer?.cancel();
    _typingStopTimer = Timer(const Duration(seconds: 3), () {
      stopTyping(roomId, username);
    });
  }

  void stopTyping(int roomId, String username) {
    _typingStopTimer?.cancel();
    _lastTypingEmit = null;
    if (_connectivityService.isOnline) {
      _webSocketService.emitStopTyping(roomId, username: username);
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    _typingSubscription?.cancel();
    _typingDebounceTimer?.cancel();
    _typingStopTimer?.cancel();
    leaveRoom();
    return super.close();
  }
}
