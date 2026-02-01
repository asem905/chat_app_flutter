import 'package:chat_app/features/chat_room/logic/cubit/chat_cubit.dart';
import 'package:chat_app/features/chat_room/logic/cubit/chat_state.dart';
import 'package:chat_app/features/chat_room/data/model/message_model.dart';
import 'package:chat_app/features/chat_room/view/widgets/date_divider.dart';
import 'package:chat_app/features/chat_room/view/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';

class MessagesListWidget extends StatelessWidget {
  final ScrollController scrollController;
  final int roomId;
  final int currentUserId;
  final ChatRoomCubit chatRoomCubit;
  final Function(MessageModel) onReply;
  final Function(MessageModel) onEdit;
  final Function(int) onDelete;

  const MessagesListWidget({
    Key? key,
    required this.scrollController,
    required this.roomId,
    required this.currentUserId,
    required this.chatRoomCubit,
    required this.onReply,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatRoomCubit, ChatRoomState>(
      bloc: chatRoomCubit,
      builder: (context, state) {
        if (state is ChatRoomLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ChatRoomLoaded || state is ChatRoomLoadingMore) {
          final messages = state is ChatRoomLoaded
              ? state.messages
              : (state as ChatRoomLoadingMore).currentMessages;

          if (messages.isEmpty) {
            return const Center(
              child: Text(
                'No messages yet.\nBe the first to say hi!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await chatRoomCubit.loadMessages(roomId, refresh: true);
            },
            child: ListView.builder(
              controller: scrollController,
              reverse: false,
              padding: const EdgeInsets.all(16),
              itemCount:
                  messages.length + (state is ChatRoomLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (state is ChatRoomLoadingMore && index == messages.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final message = messages[index];
                final previousMessage = index > 0 ? messages[index - 1] : null;
                final showDateDivider = _shouldShowDateDivider(
                  message.createdAt,
                  previousMessage?.createdAt,
                );

                return Column(
                  children: [
                    if (showDateDivider) DateDivider(date: message.createdAt),
                    MessageBubble(
                      message: message,
                      onReply: () => onReply(message),
                      onEdit: () => onEdit(message),
                      onDelete: () => onDelete(message.id),
                      currentUserId: currentUserId,
                      isPending: message.isPending == 1,
                      parentMessage: messages.firstWhereOrNull(
                        (m) => m.id == message.parentMessageId,
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  bool _shouldShowDateDivider(DateTime current, DateTime? previous) {
    if (previous == null) return true;
    return current.day != previous.day ||
        current.month != previous.month ||
        current.year != previous.year;
  }
}
