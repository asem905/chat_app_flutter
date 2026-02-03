// ignore_for_file: use_build_context_synchronously
import 'package:chat_app/core/helpers/extensions.dart';
import 'package:chat_app/core/helpers/nav_helper.dart';
import 'package:chat_app/core/helpers/shared_pref_helper.dart';
import 'package:chat_app/core/routing/routes.dart';
import 'package:chat_app/core/services/token_manager_service.dart';
import 'package:chat_app/features/home/logic/cubit/home_cubit.dart';
import 'package:chat_app/features/home/logic/cubit/home_state.dart';
import 'package:chat_app/features/home/view/widgets/create_room_dialog.dart';
import 'package:chat_app/features/home/view/widgets/room_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currnt_index = 0;
  bool isSearch = false;
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadRooms();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _showCreateRoomDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => CreateRoomDialog(
        onCreateRoom: (name, isPrivate, description) {
          if (name.isEmpty || description.isEmpty) {
            return;
          }
          context.read<HomeCubit>().createRoom(
            name,
            description,
            isPrivate: isPrivate,
          );
        },
      ),
    );
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryVeryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
              title: const Text('Profile'),
              onTap: () {
                context.pop();
                context.pushNamed(Routes.profileScreen);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryVeryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.settings, color: AppColors.primary),
              ),
              title: const Text('Settings'),
              onTap: () {
                context.pop();
                context.pushNamed(Routes.settingsScreen);
              },
            ),
            const Divider(height: 32),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.logout, color: AppColors.error),
              ),
              title: const Text(
                'Logout',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () async {
                context.pop();
                await TokenManager().clearToken();
                context.pushNamed(Routes.loginScreen);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: BottomNavigationBar(
        items: NavBottomHelper.bottomNavItems(),
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
      appBar: isSearch
          ? AppBar(
              title: TextFormField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(color: AppColors.error),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textPrimary),
                    onPressed: () {
                      searchController.clear();
                      setState(() {
                        isSearch = !isSearch;
                      });
                    },
                  ),
                  prefixIcon: IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () {
                      // Implement search functionality
                      context.read<HomeCubit>().searchRooms(
                        searchController.text,
                      );
                    },
                  ),
                ),
              ),
            )
          : CustomAppBar(
              title: 'Chats',
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: AppColors.textPrimary),
                  onPressed: () {
                    setState(() {
                      isSearch = !isSearch;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
                  tooltip: 'Refresh',
                  onPressed: () {
                    context.read<HomeCubit>().loadRooms();
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: _showMenu,
                ),
              ],
            ),

      body: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {
          if (state is HomeError) {
            print(state.message);
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
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is RoomCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Chat created successfully!'),
                  ],
                ),
                backgroundColor: AppColors.secondary,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is HomeLoading) {
            return const LoadingWidget(message: 'Loading chats...');
          }

          if (state is HomeLoaded) {
            // ✅ NEW: Show offline banner
            return Column(
              children: [
                if (state.isOffline)
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
                            'You are offline. Showing old chats.',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: state.rooms.isEmpty
                      ? EmptyStateWidget(
                          icon: Icons.chat_bubble_outline,
                          title: 'No Chats Yet',
                          message:
                              'Start a conversation by creating a new chat',
                          action: ElevatedButton.icon(
                            onPressed: _showCreateRoomDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Create Chat'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: 12.h,
                              ),
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            await context.read<HomeCubit>().refreshRooms();
                          },
                          child: ListView.builder(
                            itemCount: state.rooms.length,
                            itemBuilder: (context, index) {
                              final room = state.rooms[index];
                              return RoomListItem(
                                room: room,
                                onTap: () async {
                                  final currentUserId =
                                      await SharedPrefHelper.getInt(
                                        'current_user_id',
                                      );
                                  final currentUserName =
                                      await SharedPrefHelper.getString(
                                        'user_name',
                                      );
                                  if (room.room_created_by == currentUserId &&
                                      !state.isOffline) {
                                    context.pushNamed(
                                      Routes.roomApprovalScreen,
                                      arguments: [room.id, room.room_name],
                                    );
                                  } else {
                                    context.pushNamed(
                                      Routes.chatRoomScreen,
                                      arguments: [
                                        room.id,
                                        room.room_name,
                                        currentUserId,
                                        currentUserName,
                                      ],
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          }

          if (state is HomeError) {
            return EmptyStateWidget(
              icon: Icons.error_outline,
              title: 'Oops!',
              message: state.message,
              action: ElevatedButton(
                onPressed: () {
                  context.read<HomeCubit>().loadRooms();
                },
                child: const Text(
                  'if you are offline press here to show cached chats',
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateRoomDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
