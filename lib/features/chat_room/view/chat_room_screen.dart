import 'package:chat_app/features/chat_room/logic/cubit/chat_cubit.dart';
import 'package:chat_app/features/chat_room/view/widgets/editing_message.dart';
import 'package:chat_app/features/chat_room/view/widgets/message_input_bar.dart';
import 'package:chat_app/features/chat_room/view/widgets/reply_to.dart';
import 'package:chat_app/features/chat_room/view/widgets/typing_indicator_widget.dart';
import 'package:chat_app/features/chat_room/view/widgets/messages_list_widget.dart';
import 'package:chat_app/features/chat_room/view/widgets/offline_banner_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/features/chat_room/logic/cubit/chat_state.dart';
import 'package:chat_app/features/chat_room/data/model/message_model.dart';

class ChatRoomScreen extends StatefulWidget {
  final int roomId;
  final String roomName;
  final int currentUserId;
  final String userName;

  const ChatRoomScreen({
    super.key,
    required this.roomId,
    required this.roomName,
    required this.currentUserId,
    required this.userName,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  MessageModel? _replyingTo;
  MessageModel? _editingMessage;
  late final ChatRoomCubit _chatRoomCubit;
  @override
  void initState() {
    super.initState();
    _chatRoomCubit = context.read<ChatRoomCubit>();
    _chatRoomCubit.loadMessages(
      widget.roomId,
      currentUserId: widget.currentUserId,
    );
    _messageController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (_messageController.text.isNotEmpty) {
      _chatRoomCubit.startTyping(widget.roomId, widget.userName);
    } else {
      _chatRoomCubit.stopTyping(widget.roomId, widget.userName);
    }
  }

  // void _onScroll() {
  //   if (_scrollController.position.pixels >=
  //       _scrollController.position.maxScrollExtent - 200) {
  //     _chatRoomCubit.loadMoreMessages(widget.roomId);
  //   }
  // }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    if (_editingMessage != null) {
      _chatRoomCubit.editMessage(widget.roomId, _editingMessage!.id, content);
      _cancelEdit();
    } else {
      _chatRoomCubit.sendMessage(
        widget.roomId,
        content,
        parentMessageId: _replyingTo?.id,
      );
      _cancelReply();
    }

    _messageController.clear();
    _chatRoomCubit.stopTyping(widget.roomId, widget.userName);
  }

  void _startReply(MessageModel message) {
    setState(() {
      _replyingTo = message;
    });
    _messageFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingTo = null;
    });
  }

  void _startEdit(MessageModel message) {
    setState(() {
      _editingMessage = message;
      _messageController.text = message.content;
    });
    _messageFocusNode.requestFocus();
  }

  void _cancelEdit() {
    setState(() {
      _editingMessage = null;
      _messageController.clear();
    });
  }

  void _deleteMessage(int messageId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _chatRoomCubit.deleteMessage(widget.roomId, messageId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.roomName), elevation: 1),
      body: Column(
        children: [
          BlocListener<ChatRoomCubit, ChatRoomState>(
            bloc: _chatRoomCubit,
            listener: (context, state) {
              if (state is MessageQueued) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(state.message)),
                      ],
                    ),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 3),
                  ),
                );
              } else if (state is MessageSendError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(state.message)),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              } else if (state is ChatRoomError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(state.message)),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              } else if (state is DuplicateMessage) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(state.message)),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: Expanded(
              child: Column(
                children: [
                  OfflineBannerWidget(chatRoomCubit: _chatRoomCubit),
                  Expanded(
                    child: MessagesListWidget(
                      scrollController: _scrollController,
                      roomId: widget.roomId,
                      currentUserId: widget.currentUserId,
                      chatRoomCubit: _chatRoomCubit,
                      onReply: _startReply,
                      onEdit: _startEdit,
                      onDelete: _deleteMessage,
                    ),
                  ),
                  BlocBuilder<ChatRoomCubit, ChatRoomState>(
                    bloc: _chatRoomCubit,
                    buildWhen: (previous, current) {
                      if (previous is ChatRoomLoaded &&
                          current is ChatRoomLoaded) {
                        return previous.typingUsers != current.typingUsers;
                      }
                      return true;
                    },
                    builder: (context, state) {
                      if (state is ChatRoomLoaded) {
                        return TypingIndicatorWidget(
                          typingUsers: state.typingUsers,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
          if (_replyingTo != null)
            ReplyingToWidget(message: _replyingTo!, onCancel: _cancelReply),
          if (_editingMessage != null)
            EditingMessageWidget(
              message: _editingMessage!,
              onCancel: _cancelEdit,
            ),
          MessageInputBar(
            controller: _messageController,
            focusNode: _messageFocusNode,
            onSend: _sendMessage,
            isEditing: _editingMessage != null,
          ),
        ],
      ),
    );
  }
}
