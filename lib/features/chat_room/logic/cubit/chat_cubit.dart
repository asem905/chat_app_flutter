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
  
  StreamSubscription<MessageModel>? _messageSubscription;
  StreamSubscription<bool>? _connectionSubscription;

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
  }

  void _initConnectivityListener() {
    _connectionSubscription = _connectivityService.onConnectivityChanged.listen((isOnline) {
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
    });
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
        final messageExists = currentState.messages.any((m) => m.id == message.id);
        if (!messageExists) {
          // Remove pending message if this is the synced version
          final updatedMessages = currentState.messages
              .where((m) => m.localId != message.localId || m.id == message.id)
              .toList();
          
          emit(ChatRoomLoaded(
            messages: [message, ...updatedMessages],
            hasMore: currentState.hasMore,
            currentPage: currentState.currentPage,
            isOffline: !_connectivityService.isOnline,
          ));
        }
      }
    }
  }

  Future<void> loadMessages(int roomId, {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      emit(ChatRoomLoading());
    }

    _currentRoomId = roomId;
    
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
      emit(ChatRoomLoaded(
        messages: messages,
        hasMore: messages.length >= _pageSize,
        currentPage: _currentPage,
        isOffline: !_connectivityService.isOnline,
      ));
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

      emit(ChatRoomLoaded(
        messages: [...currentState.messages, ...newMessages],
        hasMore: newMessages.length >= _pageSize,
        currentPage: _currentPage,
        isOffline: !_connectivityService.isOnline,
      ));
    } catch (e) {
      emit(currentState);
    }
  }
  Future<void> editMessage(int roomId, int messageId, String content) async {
  try {
    await _repository.editMessage(roomId, messageId, content);
  } catch (e) {
    print('Error editing message: $e');
  }
}
  Future<void> sendMessage(int roomId, String content, {int? parentMessageId}) async {
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
      
      // Add message to UI immediately (even if pending)
      if (currentState is ChatRoomLoaded) {
        emit(ChatRoomLoaded(
          messages: [ ...currentState.messages, message ],
          hasMore: currentState.hasMore,
          currentPage: currentState.currentPage,
          isOffline: !_connectivityService.isOnline,
        ));
      }

      // Show toast if offline
      if (!_connectivityService.isOnline) {
        emit(MessageQueued('Message will be sent when online'));
        if (currentState is ChatRoomLoaded) {
          emit(currentState);
        }
      }
    } catch (e) {
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

        emit(ChatRoomLoaded(
          messages: updatedMessages,
          hasMore: currentState.hasMore,
          currentPage: currentState.currentPage,
          isOffline: !_connectivityService.isOnline,
        ));
      }
    } catch (e) {
      if (currentState is ChatRoomLoaded) {
        emit(currentState);
      }
      emit(ChatRoomError(e.toString()));
    }
  }

  void leaveRoom() {
    if (_currentRoomId != null) {
      _webSocketService.leaveRoom(_currentRoomId!);
      _currentRoomId = null;
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    leaveRoom();
    return super.close();
  }
}
