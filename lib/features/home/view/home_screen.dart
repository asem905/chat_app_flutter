import 'package:chat_app/core/helpers/extensions.dart';
import 'package:chat_app/core/routing/routes.dart';
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
  List navChoices = [
    Routes.homeScreen,
    Routes.profileScreen,
    Routes.settingsScreen,
    Routes.discoverRoomsScreen,
  ];
  List<BottomNavigationBarItem> bottomNavItems = [
    BottomNavigationBarItem(icon: const Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: const Icon(Icons.person), label: 'Profile'),
    BottomNavigationBarItem(
      icon: const Icon(Icons.settings),
      label: 'Settings',
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.family_restroom_rounded),
      label: 'Rooms',
    ),
  ];
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadRooms();
  }

  void _showCreateRoomDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => CreateRoomDialog(
        onCreateRoom: (name, isPrivate, description) {
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person, color: AppColors.primary),
              title: const Text('Profile'),
              onTap: () {
                context.pop();
                // Navigate to profile
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: AppColors.primary),
              title: const Text('Settings'),
              onTap: () {
                context.pop();
                // Navigate to settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Logout'),
              onTap: () {
                context.pop();
                context.read<HomeCubit>().logout();
                // Navigate to login
              },
            ),
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
        items:bottomNavItems,
        currentIndex: currnt_index,
        onTap: (index) {
          setState(() {
            currnt_index = index;
            context.pushNamed(navChoices[index]);
          });
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      appBar: CustomAppBar(
        title: 'Chats',
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textPrimary),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onPressed: _showMenu,
          ),
          //show all rooms button
          IconButton(
            icon: const Icon(Icons.list, color: AppColors.textPrimary),
            onPressed: () {
              context.pushNamed(Routes.discoverRoomsScreen);
            },
          ),
        ],
      ),

      body: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {
          if (state is HomeError) {
            print(state.message);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is RoomCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Chat created successfully!'),
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
            if (state.rooms.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.chat_bubble_outline,
                title: 'No Chats Yet',
                message: 'Start a conversation by creating a new chat',
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
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<HomeCubit>().refreshRooms();
              },
              child: ListView.builder(
                itemCount: state.rooms.length,
                itemBuilder: (context, index) {
                  final room = state.rooms[index];
                  return RoomListItem(
                    room: room,
                    onTap: () {
                      context.pushNamed(
                        Routes.roomApprovalScreen,
                        arguments: [room.id, room.room_name],
                      );
                    },
                  );
                },
              ),
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
                child: const Text('Retry'),
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
