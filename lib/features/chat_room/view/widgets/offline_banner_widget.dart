import 'package:chat_app/features/chat_room/logic/cubit/chat_cubit.dart';
import 'package:chat_app/features/chat_room/logic/cubit/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OfflineBannerWidget extends StatelessWidget {
  final ChatRoomCubit chatRoomCubit;

  const OfflineBannerWidget({Key? key, required this.chatRoomCubit})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatRoomCubit, ChatRoomState>(
      bloc: chatRoomCubit,
      buildWhen: (previous, current) {
        // Only rebuild when offline status changes
        if (previous is ChatRoomLoaded && current is ChatRoomLoaded) {
          return previous.isOffline != current.isOffline;
        }
        return true;
      },
      builder: (context, state) {
        if (state is! ChatRoomLoaded || !state.isOffline) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          color: Colors.orange.shade700,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: const [
              Icon(Icons.cloud_off, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'You are offline. Messages will be sent when online.',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
