// ignore_for_file: library_prefixes

import 'dart:async';
import 'package:chat_app/core/helpers/get_token.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:chat_app/features/chat_room/data/model/message_model.dart';
import 'package:chat_app/core/networking/api_constants.dart';

class WebSocketService {
  IO.Socket? _socket;

  final _messageController = StreamController<MessageModel>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<MessageModel> get onNewMessage => _messageController.stream;
  Stream<bool> get onConnectionChange => _connectionController.stream;
  Stream<Map<String, dynamic>> get onTyping => _typingController.stream;

  bool get isConnected => _socket?.connected ?? false;

  WebSocketService();

  void connect() async {
    final result = await getTokenAndCurrentUserId();
    final token = result['token'];
    if (_socket?.connected ?? false) {
      print('WebSocket already connected');
      return;
    }
    print('WebSocket connecting...');
    _socket = IO.io(
      ApiConstants.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setAuth({'Authorization': 'Bearer $token'})
          .build(),
    );
    _setupEventListeners();
  }

  void _setupEventListeners() async {
    final result = await getTokenAndCurrentUserId();
    final currentUserId = result['currentUserId'];
    _socket?.onConnect((_) {
      print('✅ WebSocket connected');
      _connectionController.add(true);
    });

    _socket?.onDisconnect((_) {
      print('❌ WebSocket disconnected');
      _connectionController.add(false);
    });

    _socket?.on('newMessage', (data) {
      print('📨 Received new message: $data');
      try {
        final message = MessageModel.fromJson(data, currentUserId);
        _messageController.add(message);
      } catch (e) {
        print('Error parsing message: $e');
      }
    });
    _socket?.on('userTyping', (data) {
      print('User typing event: $data');
      try {
        _typingController.add(data as Map<String, dynamic>);
      } catch (e) {
        print('Error parsing typing event: $e');
      }
    });
    _socket?.on('userStoppedTyping', (data) {
      print('User stop typing event: $data');
      try {
        _typingController.add(data as Map<String, dynamic>);
      } catch (e) {
        print('Error parsing typing event: $e');
      }
    });
    _socket?.on('error', (data) {
      print('Socket error: $data');
    });
  }

  void joinRoom(int roomId) {
    if (_socket?.connected ?? false) {
      _socket?.emit('joinRoom', roomId.toString());
      print('Joining room: $roomId');
    }
  }

  void leaveRoom(int roomId) {
    if (_socket?.connected ?? false) {
      _socket?.emit('leaveRoom', roomId.toString());
      print('Leaving room: $roomId');
    }
  }

  void emitTyping(int roomId, String username) {
    print("user $username is trying to typing in room of id $roomId");
    print("socket connected: ${_socket?.connected}");
    if (_socket?.connected ?? false) {
      _socket?.emit('typing', {
        'roomId': roomId.toString(),
        'username': username,
      });
    }
  }

  void emitStopTyping(int roomId, {String? username}) {
    if (_socket?.connected ?? false) {
      _socket?.emit('stopTyping', {
        'roomId': roomId.toString(),
        'username': username,
      });
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _connectionController.close();
    _typingController.close();
  }
}
