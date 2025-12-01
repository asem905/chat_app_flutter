// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/text_styles.dart';

class ApproveRejectDialog extends StatelessWidget {
  final String username;
  final bool isApprove;
  final VoidCallback onConfirm;

  const ApproveRejectDialog({
    Key? key,
    required this.username,
    required this.isApprove,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: (isApprove ? AppColors.secondary : AppColors.error)
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isApprove ? Icons.check_circle : Icons.cancel,
                size: 32,
                color: isApprove ? AppColors.secondary : AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isApprove ? 'Approve User?' : 'Reject User?',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isApprove
                  ? 'Are you sure you want to approve $username to join this room?'
                  : 'Are you sure you want to reject $username\'s request to join this room?',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.border, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isApprove ? AppColors.secondary : AppColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(isApprove ? 'Approve' : 'Reject'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}