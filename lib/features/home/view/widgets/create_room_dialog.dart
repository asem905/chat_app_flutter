// file: lib/features/home/view/widgets/create_room_dialog.dart

import 'package:chat_app/core/theming/text_styles.dart';
import 'package:chat_app/core/widgets/app_custom_button.dart';
import 'package:chat_app/core/widgets/app_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theming/app_colors.dart';

class CreateRoomDialog extends StatefulWidget {
  final Function(String name, bool isPrivate, String description) onCreateRoom;

  const CreateRoomDialog({super.key, required this.onCreateRoom});

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
    _descriptionController.dispose(); // Added dispose for description controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // 🐛 FIX 1: Wrap the Dialog content in a SingleChildScrollView 
      // to handle overflow when the keyboard is visible.
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create New Chat', style: AppTextStyles.heading2),
              SizedBox(height: 20.h),
              CustomTextFormField(
                controller: _nameController,
                hintText: 'Enter chat name',
                labelText: 'Chat Name',
                prefixIcon: const Icon(Icons.chat_bubble_outline),
              ),
              SizedBox(height: 16.h),
              CustomTextFormField(
                controller: _descriptionController,
                hintText: 'Enter description',
                labelText: 'Description',
                prefixIcon: const Icon(Icons.description_outlined),
              ),
              SizedBox(height: 16.h),
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
              SizedBox(height: 24.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Wrapping TextButton with Expanded to properly fill space
                  Expanded( 
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  CustomButton(
                    text: 'Create',
                    onPressed: () {
                      if (_nameController.text.trim().isNotEmpty) {
                        widget.onCreateRoom(
                          _nameController.text.trim(),
                          _isPrivate,
                          _descriptionController.text.trim(),
                        );
                        Navigator.pop(context);
                      }
                    },
                    // width and height can stay as they are, but ensuring the
                    // internal Row in CustomButton is fixed (see below) is crucial.
                    width: 105.w,
                    height: 40.h,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}