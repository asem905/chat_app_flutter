import 'package:chat_app/features/login/data/model/user_model.dart';
import 'package:flutter/material.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/text_styles.dart';
import '../../../../core/widgets/avatar_widget.dart';

class PendingUserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final bool isProcessing;

  const PendingUserCard({
    super.key,
    required this.user,
    required this.onApprove,
    required this.onReject,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            AvatarWidget(name: user.username!, size: 56),

            const SizedBox(width: 12),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username!,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          user.email!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  // if (user. != null) ...[
                  //   const SizedBox(height: 4),
                  //   Row(
                  //     children: [
                  //       const Icon(
                  //         Icons.access_time,
                  //         size: 14,
                  //         color: AppColors.textSecondary,
                  //       ),
                  //       const SizedBox(width: 4),
                  //       Text(
                  //         'Requested ${timeago.format(user.requestedAt!)}',
                  //         style: AppTextStyles.bodyMedium.copyWith(
                  //           fontSize: 12,
                  //           color: AppColors.textSecondary,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ],
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Action Buttons
            Column(
              children: [
                // Approve Button
                Material(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: isProcessing ? null : onApprove,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Reject Button
                Material(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: isProcessing ? null : onReject,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
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
