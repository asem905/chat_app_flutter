import 'package:chat_app/features/chat_room/data/model/message_model.dart';
import 'package:equatable/equatable.dart';

abstract class ChatRoomState extends Equatable {
  @override
  List<Object> get props => [];
}

class ChatRoomInitial extends ChatRoomState {}

class ChatRoomLoading extends ChatRoomState {}

class ChatRoomLoadingMore extends ChatRoomState {
  final List<MessageModel> currentMessages;

  ChatRoomLoadingMore(this.currentMessages);
  @override
  List<Object> get props => [currentMessages];
}

class ChatRoomError extends ChatRoomState {
  final String message;
  ChatRoomError(this.message);
  @override
  List<Object> get props => [message];
}

class MessageSending extends ChatRoomState {}

class MessageSent extends ChatRoomState {
  final MessageModel message;
  MessageSent(this.message);
  @override
  List<Object> get props => [message];
}

class MessageSendError extends ChatRoomState {
  final String message;
  MessageSendError(this.message);
  @override
  List<Object> get props => [message];
}

class MessageDeleting extends ChatRoomState {
  final int messageId;
  MessageDeleting(this.messageId);
  @override
  List<Object> get props => [messageId];
}

class MessageDeleted extends ChatRoomState {
  final int messageId;
  MessageDeleted(this.messageId);
  @override
  List<Object> get props => [messageId];
}

class MessageEditing extends ChatRoomState {
  final int messageId;
  MessageEditing(this.messageId);
  @override
  List<Object> get props => [messageId];
}

class MessageEdited extends ChatRoomState {
  final MessageModel message;
  MessageEdited(this.message);
  @override
  List<Object> get props => [message];
}

class UserTyping extends ChatRoomState {
  final String username;
  UserTyping(this.username);
  @override
  List<Object> get props => [username];
}

class UserStoppedTyping extends ChatRoomState {}

class ChatRoomLoaded extends ChatRoomState {
  final List<MessageModel> messages;
  final bool hasMore;
  final int currentPage;
  final bool isOffline; // ✅ NEW
  final Map<int, String> typingUsers; // userId -> username

  ChatRoomLoaded({
    required this.messages,
    required this.hasMore,
    required this.currentPage,
    this.isOffline = false, // ✅ NEW
    this.typingUsers = const {}, // ✅ NEW
  });

  @override
  List<Object> get props => [
    messages,
    hasMore,
    currentPage,
    isOffline,
    typingUsers,
  ];
}

// ✅ NEW STATE
class MessageQueued extends ChatRoomState {
  final String message;
  MessageQueued(this.message);

  @override
  List<Object> get props => [message];
}

class DuplicateMessage extends ChatRoomState {
  final String message;
  DuplicateMessage(this.message);
  @override
  List<Object> get props => [message];
}
