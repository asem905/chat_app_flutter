// ignore_for_file: deprecated_member_use

import 'package:chat_app/features/chat_room/data/model/message_model.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/text_styles.dart';
import '../../../../core/widgets/avatar_widget.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReply;
  final bool showAvatar;
  final int? currentUserId;
  final bool isPending; // ✅ NEW

  const MessageBubble({
    Key? key,
    required this.message,
    this.onEdit,
    this.onDelete,
    this.onReply,
    this.showAvatar = true,
    this.currentUserId,
    this.isPending =
        false, // ✅ NEW - defaults to false for backward compatibility
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(
      "current user id: ${message.userId == (currentUserId) ? "You" : message.username}",
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: message.isMine == 1
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!(message.isMine == 1 ? true : false) && showAvatar) ...[
            AvatarWidget(
              imageUrl: null,
              name: message.userId == (currentUserId)
                  ? "You"
                  : message.username!,
              size: 32,
            ),
            const SizedBox(width: 8),
          ] else if (!(message.isMine == 1 ? true : false) && !showAvatar)
            const SizedBox(width: 40),

          Flexible(
            child: GestureDetector(
              onLongPress: () => _showMessageOptions(context, message.isMine),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: message.isDeleted == 1
                      ? AppColors.border
                      : (message.isMine == 1 ? true : false)
                      ? (isPending
                            ? AppColors.primary.withOpacity(
                                0.7,
                              ) // ✅ Dimmed when pending
                            : AppColors.primary)
                      : AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(
                      (message.isMine == 1 ? true : false) ? 16 : 4,
                    ),
                    bottomRight: Radius.circular(
                      (message.isMine == 1 ? true : false) ? 4 : 16,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!(message.isMine == 1 ? true : false) &&
                        showAvatar) ...[
                      Text(
                        message.userId == currentUserId
                            ? "You"
                            : message.username!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      message.isDeleted == 1
                          ? 'This message was deleted'
                          : message.content,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: message.isDeleted == 1
                            ? AppColors.textSecondary
                            : (message.isMine == 1 ? true : false)
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontStyle: message.isDeleted == 1
                            ? FontStyle.italic
                            : null,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeago.format(message.createdAt, locale: 'en_short'),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 11,
                            color: (message.isMine == 1 ? true : false)
                                ? Colors.white.withOpacity(0.8)
                                : AppColors.textSecondary,
                          ),
                        ),
                        if ((message.isEdited == 1 ? true : false) &&
                            !(message.isDeleted == 1)) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(edited)',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: (message.isMine == 1 ? true : false)
                                  ? Colors.white.withOpacity(0.7)
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],

                        // ✅ NEW: Status indicator for sent messages
                        if ((message.isMine == 1 ? true : false) &&
                            !(message.isDeleted == 1)) ...[
                          const SizedBox(width: 6),
                          if (isPending)
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: Colors.white.withOpacity(0.7),
                            ) // ⏱️ Pending/Queued
                          else
                            Icon(
                              Icons.done_all,
                              size: 14,
                              color: Colors.white.withOpacity(0.9),
                            ), // ✓✓ Sent/Delivered
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          if ((message.isMine == 1 ? true : false) && showAvatar) ...[
            const SizedBox(width: 8),
            AvatarWidget(
              imageUrl: null,
              name: message.userId == (currentUserId)
                  ? "You"
                  : message.username!,
              size: 32,
            ),
          ] else if ((message.isMine == 1 ? true : false) && !showAvatar)
            const SizedBox(width: 40),
        ],
      ),
    );
  }

  void _showMessageOptions(BuildContext context, isMine) {
  if (message.isDeleted == 1) return;

  final replyCallback = onReply;
  final editCallback = onEdit;
  final deleteCallback = onDelete;

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (bottomSheetContext) => Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (replyCallback != null)
            ListTile(
              leading: const Icon(Icons.reply, color: AppColors.primary),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(bottomSheetContext); 
                replyCallback(); 
              },
            ),
          if (isMine != 1)
            if (editCallback != null)
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.primary),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(bottomSheetContext); 
                  editCallback(); 
                },
              ),
          if (deleteCallback != null)
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(bottomSheetContext); 
                deleteCallback(); 
              },
            ),
        ],
      ),
    ),
  );
}
}
