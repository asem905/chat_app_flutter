// ignore_for_file: non_constant_identifier_names

import 'package:chat_app/core/helpers/extensions.dart';
import 'package:chat_app/core/helpers/nav_helper.dart';
import 'package:chat_app/core/widgets/avatar_widget.dart';
import 'package:chat_app/features/home/logic/cubit/discover_rooms_cubit.dart';
import 'package:chat_app/features/home/logic/cubit/discover_rooms_state.dart';
import 'package:chat_app/features/home/view/widgets/available_rooms_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';


class DiscoverRoomsScreen extends StatefulWidget {
  const DiscoverRoomsScreen({super.key});

  @override
  State<DiscoverRoomsScreen> createState() => _DiscoverRoomsScreenState();
}

class _DiscoverRoomsScreenState extends State<DiscoverRoomsScreen> {
  final TextEditingController _searchController = TextEditingController();
  int? _joiningRoomId;
  int currnt_index = 3;
  
  @override
  void initState() {
    super.initState();
    context.read<DiscoverRoomsCubit>().loadAvailableRooms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<DiscoverRoomsCubit>().searchRooms(query);
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<DiscoverRoomsCubit>().searchRooms('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: AppColors.background,
      bottomNavigationBar: BottomNavigationBar(
        items:NavBottomHelper.bottomNavItems(),
        currentIndex: currnt_index,
        onTap: (index) {
          setState(() {
            currnt_index = index;
            context.pushNamed(NavBottomHelper.navChoices()[index]);
          });
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      appBar: CustomAppBar(
        title: 'Discover Rooms',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<DiscoverRoomsCubit, DiscoverRoomsState>(
        listener: (context, state) {
          if (state is RoomJoined) {
            setState(() => _joiningRoomId = null);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text('Successfully joined "${state.roomName}"!'),
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
          } else if (state is JoinRoomError) {
            setState(() => _joiningRoomId = null);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    SizedBox(width: 12.w),
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
          } else if (state is JoiningRoom) {
            setState(() => _joiningRoomId = state.roomId);
          }
        },
        builder: (context, state) {
          if (state is DiscoverRoomsLoading) {
            return const LoadingWidget(message: 'Loading available rooms...');
          }

          if (state is DiscoverRoomsLoaded) {
            return Column(
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      bottom: BorderSide(color: AppColors.border, width: 1),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search rooms...',
                      hintStyle: AppTextStyles.bodyMedium,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: _clearSearch,
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2.w,
                        ),
                      ),
                    ),
                  ),
                ),

                // Rooms List
                Expanded(
                  child: state.filteredRooms.isEmpty
                      ? EmptyStateWidget(
                          icon: state.searchQuery.isNotEmpty
                              ? Icons.search_off
                              : Icons.forum_outlined,
                          title: state.searchQuery.isNotEmpty
                              ? 'No Rooms Found'
                              : 'No Available Rooms',
                          message: state.searchQuery.isNotEmpty
                              ? 'Try adjusting your search terms'
                              : 'Check back later for new rooms',
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            await context.read<DiscoverRoomsCubit>().refreshRooms();
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.filteredRooms.length,
                            itemBuilder: (context, index) {
                              final room = state.filteredRooms[index];
                              return AvailableRoomCard(
                                room: room,
                                isJoining: _joiningRoomId == room.room_id,
                                onJoin: () {
                                  context.read<DiscoverRoomsCubit>().joinRoom(
                                        room.room_id,
                                        room.room_name,
                                      );
                                },
                                onTap: () {
                                  // Show room details dialog or navigate to room
                                  _showRoomDetailsDialog(context, room);
                                },
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          }

          if (state is DiscoverRoomsError) {
            return EmptyStateWidget(
              icon: Icons.error_outline,
              title: 'Oops!',
              message: state.message,
              action: ElevatedButton.icon(
                onPressed: () {
                  context.read<DiscoverRoomsCubit>().loadAvailableRooms();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
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

  void _showRoomDetailsDialog(BuildContext context, room) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AvatarWidget(
                imageUrl: room.imageUrl,
                name: room.name,
                size: 80,
              ),
              SizedBox(height: 16.h),
              Text(
                room.name,
                style: AppTextStyles.heading2,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              if (room.description != null) ...[
                Text(
                  room.description,
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildInfoChip(
                    Icons.person_outline,
                    '${room.memberCount} members',
                  ),
                  SizedBox(width: 12.w),
                  if (room.isPrivate)
                    _buildInfoChip(
                      Icons.lock_outline,
                      'Private',
                    ),
                ],
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(color: AppColors.border, width: 2.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                  if (!room.isJoined) ...[
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          context.read<DiscoverRoomsCubit>().joinRoom(
                                room.id,
                                room.name,
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Join Room'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}