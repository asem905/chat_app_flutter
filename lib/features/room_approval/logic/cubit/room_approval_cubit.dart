import 'package:chat_app/features/room_approval/data/repos/room_approval_repo.dart';
import 'package:chat_app/features/room_approval/logic/cubit/room_approval_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RoomApprovalCubit extends Cubit<RoomApprovalState> {
  final RoomApprovalRepository _repository;

  RoomApprovalCubit(
    this._repository,
  ) : super(RoomApprovalInitial());

  Future<void> loadPendingUsers( int roomId) async {
    emit(RoomApprovalLoading());

    try {
      print(await _repository.getPendingUsers(roomId));
      final users = await _repository.getPendingUsers(roomId).then((value) => value.users);
      print("users pended: $users");
      if (users.isEmpty) {
        emit(RoomApprovalEmpty());
      } else {
        emit(RoomApprovalLoaded(
          pendingUsers: users,
        ));
      }
    } catch (e) {
      emit(RoomApprovalError(e.toString()));
    }
  }

  Future<void> approveUser(int userId, String username,int roomId) async {
    final currentState = state;
    emit(ApprovingUser(userId));

    try {
      await _repository.approveUser(roomId, userId);
      emit(UserApproved(username));

      // Reload the list
      await loadPendingUsers(roomId);
    } catch (e) {
      if (currentState is RoomApprovalLoaded) {
        emit(currentState);
      }
      emit(ApprovalActionError(e.toString()));

      // Return to previous state
      if (currentState is RoomApprovalLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> rejectUser(int userId, String username,int roomId) async {
    final currentState = state;
    emit(RejectingUser(userId));

    try {
      await _repository.rejectUser(roomId, userId);
      emit(UserRejected(username));

      // Reload the list
      await loadPendingUsers(roomId);
    } catch (e) {
      if (currentState is RoomApprovalLoaded) {
        emit(currentState);
      }
      emit(ApprovalActionError(e.toString()));

      // Return to previous state
      if (currentState is RoomApprovalLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> refreshPendingUsers(int roomId) async {
    await loadPendingUsers(roomId);
  }
}