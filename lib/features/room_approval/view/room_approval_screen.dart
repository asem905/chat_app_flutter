// ignore_for_file: deprecated_member_use

import 'package:chat_app/core/helpers/extensions.dart';
import 'package:chat_app/core/helpers/shared_pref_helper.dart';
import 'package:chat_app/core/routing/routes.dart';
import 'package:chat_app/features/room_approval/logic/cubit/room_approval_cubit.dart';
import 'package:chat_app/features/room_approval/logic/cubit/room_approval_state.dart';
import 'package:chat_app/features/room_approval/view/widgets/approve_reject_dialog.dart';
import 'package:chat_app/features/room_approval/view/widgets/pending_user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';

class RoomApprovalScreen extends StatefulWidget {
  final int roomId;
  final String roomName;

  const RoomApprovalScreen({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  @override
  State<RoomApprovalScreen> createState() => _RoomApprovalScreenState();
}

class _RoomApprovalScreenState extends State<RoomApprovalScreen> {
  int? _processingUserId;

  @override
  void initState() {
    super.initState();
    context.read<RoomApprovalCubit>().loadPendingUsers();
  }

  void _showApproveDialog(int userId, String username) {
    showDialog(
      context: context,
      builder: (dialogContext) => ApproveRejectDialog(
        username: username,
        isApprove: true,
        onConfirm: () {
          context.read<RoomApprovalCubit>().approveUser(userId, username);
        },
      ),
    );
  }

  void _showRejectDialog(int userId, String username) {
    showDialog(
      context: context,
      builder: (dialogContext) => ApproveRejectDialog(
        username: username,
        isApprove: false,
        onConfirm: () {
          context.read<RoomApprovalCubit>().rejectUser(userId, username);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Pending Approvals',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final currentUserId = await SharedPrefHelper.getInt(
            'current_user_id',
          );
          final currentUserName = await SharedPrefHelper.getString('user_name');
          context.pushNamed(
            Routes.chatRoomScreen,
            arguments: [
              widget.roomId,
              widget.roomName,
              currentUserId,
              currentUserName,
            ],
          );
        },
        backgroundColor: AppColors.surface,

        child: Icon(
          Icons.chat_outlined,
          color: AppColors.secondary,
          size: 38.sp,
        ),
      ),
      body: BlocConsumer<RoomApprovalCubit, RoomApprovalState>(
        listener: (context, state) {
          if (state is UserApproved) {
            setState(() => _processingUserId = null);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('${state.username} approved successfully!'),
                    ),
                  ],
                ),
                backgroundColor: AppColors.secondary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          } else if (state is UserRejected) {
            setState(() => _processingUserId = null);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text('${state.username} rejected')),
                  ],
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          } else if (state is ApprovalActionError) {
            setState(() => _processingUserId = null);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          } else if (state is ApprovingUser) {
            setState(() => _processingUserId = state.userId);
          } else if (state is RejectingUser) {
            setState(() => _processingUserId = state.userId);
          }
        },
        builder: (context, state) {
          if (state is RoomApprovalLoading) {
            return const LoadingWidget(message: 'Loading pending users...');
          }

          if (state is RoomApprovalEmpty) {
            return EmptyStateWidget(
              icon: Icons.check_circle_outline,
              title: 'All Caught Up!',
              message: 'No pending approval requests for ${widget.roomName}',
            );
          }

          if (state is RoomApprovalLoaded) {
            if (!state.isOnline) {
              //return beautiful offline ui
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_off,
                      size: 80,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'You are offline',
                      style: AppTextStyles.headingMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please check your internet connection',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: [
                // Header Info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: const Border(
                      bottom: BorderSide(color: AppColors.border, width: 1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.roomName,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.people_outline,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${state.pendingUsers.length} pending',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Pending Users List
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await context
                          .read<RoomApprovalCubit>()
                          .refreshPendingUsers();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.pendingUsers.length,
                      itemBuilder: (context, index) {
                        final user = state.pendingUsers[index];
                        return PendingUserCard(
                          user: user,
                          isProcessing: _processingUserId == user.id,
                          onApprove: () {
                            _showApproveDialog(user.id, user.username);
                          },
                          onReject: () {
                            _showRejectDialog(user.id, user.username);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }

          if (state is RoomApprovalError) {
            return EmptyStateWidget(
              icon: Icons.error_outline,
              title: 'Oops!',
              message: state.message,
              action: ElevatedButton.icon(
                onPressed: () {
                  context.read<RoomApprovalCubit>().loadPendingUsers();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
