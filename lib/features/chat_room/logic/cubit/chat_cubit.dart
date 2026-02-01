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
  static const int _pageSize = 200;
  int? _currentRoomId;
  int? _currentUserId;

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
          print('Back online! Syncing pending messages...');
          _syncPendingMessages();
          if (_currentRoomId != null) {
            _webSocketService.joinRoom(_currentRoomId!);
          }
        } else {
          print('Gone offline. Messages will be queued.');
        }
      },
    );
  }

  Future<void> _syncPendingMessages() async {
    try {
      await _repository.syncPendingMessages();

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
        bool messageExists = false;
        if (message.id > 0) {
          messageExists = currentState.messages.any((m) => m.id == message.id);
        }

        if (!messageExists) {
          final updatedMessages = currentState.messages.toList();
          _repository
              .cacheMessage(message)
              .then((_) {
                print("Message cached successfully");
              })
              .catchError((e) {
                print("Failed to cache message: $e");
              });

          final newState = ChatRoomLoaded(
            messages: [...updatedMessages, message],
            hasMore: currentState.hasMore,
            currentPage: currentState.currentPage,
            isOffline: !_connectivityService.isOnline,
            typingUsers: currentState.typingUsers,
          );
          emit(newState);
        } else {
          print("Message already exists, skipping");
        }
      } else {
        print(
          "Message for different room (${message.roomId} vs $_currentRoomId), skipping",
        );
      }
    } else {
      print("Current state is not ChatRoomLoaded, it's ${state.runtimeType}");
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

    if (userId == _currentUserId) {
      return;
    }

    final updatedTypingUsers = Map<int, String>.from(currentState.typingUsers);

    if (isTyping && username != null) {
      updatedTypingUsers[userId] = username;
    } else {
      updatedTypingUsers.remove(userId);
    }

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
      _currentUserId = currentUserId;
    }

    if (_connectivityService.isOnline) {
      _webSocketService.joinRoom(roomId);
    }

    try {
      final messages = await _repository.getMessages(roomId);
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

      final message = await _repository.sendMessage(roomId, request);

      if (message.id == 0) {
        return;
      }

      if (currentState is ChatRoomLoaded) {
        final newState = ChatRoomLoaded(
          messages: [...currentState.messages, message],
          hasMore: currentState.hasMore,
          currentPage: currentState.currentPage,
          isOffline: !_connectivityService.isOnline,
          typingUsers: currentState.typingUsers,
        );

        emit(newState);
      }

      if (!_connectivityService.isOnline) {
        emit(MessageQueued('Message will be sent when online'));
        if (currentState is ChatRoomLoaded) {
          emit(currentState);
        }
      }
    } catch (e) {
      if (e.toString().contains('409')) {
        emit(DuplicateMessage('Message already sent'));
        if (currentState is ChatRoomLoaded) {
          emit(currentState);
        }
        return;
      }
      emit(MessageSendError(e.toString()));
      if (currentState is ChatRoomLoaded) {
        emit(currentState);
      }
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
    if (_lastTypingEmit != null &&
        now.difference(_lastTypingEmit!).inSeconds < 2) {
      return;
    }
    print(
      'user(in start typing function) $username is typing in room of id $roomId',
    );
    _webSocketService.emitTyping(roomId, username);
    _lastTypingEmit = now;

    _typingStopTimer?.cancel();
    _typingStopTimer = Timer(const Duration(seconds: 3), () {
      stopTyping(roomId, username);
    });
  }

  void stopTyping(int roomId, String username) {
    if (_connectivityService.isOnline) {
      _webSocketService.emitStopTyping(roomId, username: username);
    }
    _typingStopTimer?.cancel();
    _lastTypingEmit = null;
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
