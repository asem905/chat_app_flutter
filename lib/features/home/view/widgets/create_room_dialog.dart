import 'package:chat_app/core/theming/text_styles.dart';
import 'package:chat_app/core/widgets/app_custom_button.dart';
import 'package:chat_app/core/widgets/app_text_form_field.dart';
import 'package:flutter/material.dart';
import '../../../../core/theming/app_colors.dart';

class CreateRoomDialog extends StatefulWidget {
  final Function(String name, bool isPrivate, String description) onCreateRoom;

  const CreateRoomDialog({Key? key, required this.onCreateRoom})
    : super(key: key);

  @override
  State<CreateRoomDialog> createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<CreateRoomDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPrivate = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create New Chat', style: AppTextStyles.heading2),
            const SizedBox(height: 20),
            CustomTextFormField(
              controller: _nameController,
              hintText: 'Enter chat name',
              labelText: 'Chat Name',
              prefixIcon: const Icon(Icons.chat_bubble_outline),
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: _descriptionController,
              hintText: 'Enter description',
              labelText: 'Description',
              prefixIcon: const Icon(Icons.description_outlined),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isPrivate,
                  onChanged: (value) {
                    setState(() => _isPrivate = value!);
                  },
                  activeColor: AppColors.primary,
                ),
                const Text('Private Chat'),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                CustomButton(
                  text: 'Create',
                  onPressed: () {
                    if (_nameController.text.trim().isNotEmpty) {
                      widget.onCreateRoom(
                        _nameController.text.trim(),
                        _isPrivate,
                        '',
                      );
                      Navigator.pop(context);
                    }
                  },
                  width: 100,
                  height: 40,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
