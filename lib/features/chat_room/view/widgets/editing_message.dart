import 'package:chat_app/features/chat_room/data/model/message_model.dart';
import 'package:flutter/material.dart';

class EditingMessageWidget extends StatelessWidget {
  final MessageModel message;
  final VoidCallback onCancel;

  const EditingMessageWidget({
    Key? key,
    required this.message,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border(
          top: BorderSide(color: Colors.orange[200]!),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.edit,
            size: 20,
            color: Colors.orange[700],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Edit Message',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[700],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message.content,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: onCancel,
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }
}