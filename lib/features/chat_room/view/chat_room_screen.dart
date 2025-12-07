import 'package:chat_app/features/chat_room/logic/cubit/chat_cubit.dart';
import 'package:chat_app/features/chat_room/view/widgets/date_divider.dart';
import 'package:chat_app/features/chat_room/view/widgets/editing_message.dart';
import 'package:chat_app/features/chat_room/view/widgets/message_bubble.dart';
import 'package:chat_app/features/chat_room/view/widgets/message_input_bar.dart';
import 'package:chat_app/features/chat_room/view/widgets/reply_to.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/features/chat_room/logic/cubit/chat_state.dart';
import 'package:chat_app/features/chat_room/data/model/message_model.dart';

class ChatRoomScreen extends StatefulWidget {
  final int roomId;
  final String roomName;
  final int currentUserId;

  const ChatRoomScreen({
    Key? key,
    required this.roomId,
    required this.roomName,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  MessageModel? _replyingTo;
  MessageModel? _editingMessage;

  @override
  void initState() {
    super.initState();
    context.read<ChatRoomCubit>().loadMessages(widget.roomId);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ChatRoomCubit>().loadMoreMessages(widget.roomId);
    }
  }

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
      context.read<ChatRoomCubit>().editMessage(
        widget.roomId,
        _editingMessage!.id,
        content,
      );
      _cancelEdit();
    } else {
      context.read<ChatRoomCubit>().sendMessage(
        widget.roomId,
        content,
        parentMessageId: _replyingTo?.id,
      );
      _cancelReply();
    }

    _messageController.clear();
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
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ChatRoomCubit>().deleteMessage(
                widget.roomId,
                messageId,
              );
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
          Expanded(
            child: BlocConsumer<ChatRoomCubit, ChatRoomState>(
              listener: (context, state) {
                // ✅ NEW: Handle queued messages
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
                }
              },
              builder: (context, state) {
                if (state is ChatRoomLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ChatRoomLoaded || state is ChatRoomLoadingMore) {
                  final messages = state is ChatRoomLoaded
                      ? state.messages
                      : (state as ChatRoomLoadingMore).currentMessages;

                  final isOffline = state is ChatRoomLoaded
                      ? state.isOffline
                      : false;

                  if (messages.isEmpty) {
                    return const Center(
                      child: Text(
                        'No messages yet.\nBe the first to say hi!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Offline Banner
                      if (isOffline)
                        Container(
                          width: double.infinity,
                          color: Colors.orange.shade700,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.cloud_off,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'You are offline. Messages will be sent when online.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Messages List
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await context.read<ChatRoomCubit>().loadMessages(
                              widget.roomId,
                              refresh: true,
                            );
                          },
                          child: ListView.builder(
                            controller: _scrollController,
                            reverse: false,
                            padding: const EdgeInsets.all(16),
                            itemCount:
                                messages.length +
                                (state is ChatRoomLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (state is ChatRoomLoadingMore &&
                                  index == messages.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              final message = messages[index];
                              final previousMessage = index > 0
                                  ? messages[index - 1]
                                  : null;
                              final showDateDivider = _shouldShowDateDivider(
                                message.createdAt,
                                previousMessage?.createdAt,
                              );

                              return Column(
                                children: [
                                  if (showDateDivider)
                                    DateDivider(date: message.createdAt),
                                  MessageBubble(
                                    message: message,
                                    onReply: () => _startReply(message),
                                    onEdit: () => _startEdit(message),
                                    onDelete: () => _deleteMessage(message.id),
                                    currentUserId: widget.currentUserId,
                                    isPending: message
                                        .isPending==1, // ✅ Show pending state
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return const SizedBox();
              },
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

  bool _shouldShowDateDivider(DateTime current, DateTime? previous) {
    if (previous == null) return true;
    return current.day != previous.day ||
        current.month != previous.month ||
        current.year != previous.year;
  }
}
