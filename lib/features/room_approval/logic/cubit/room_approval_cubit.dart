import 'dart:async';

import 'package:chat_app/core/services/internet_connectivity_service.dart';
import 'package:chat_app/features/room_approval/data/repos/room_approval_repo.dart';
import 'package:chat_app/features/room_approval/logic/cubit/room_approval_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RoomApprovalCubit extends Cubit<RoomApprovalState> {
  final RoomApprovalRepository _repository;
  final ConnectivityService _connectivityService;
  StreamSubscription<bool>? _connectivitySubscription;
  int roomId;
  RoomApprovalCubit(this._repository, this._connectivityService, this.roomId)
    : super(RoomApprovalInitial()) {
    _initConnectivityListener();
  }
  void _initConnectivityListener() {
    _connectivitySubscription = _connectivityService.onConnectivityChanged
        .listen((isOnline) {
          if (isOnline) {
            print('🌐 Back online! Refreshing rooms...');
            _refreshInBackground();
          } else {
            print('📵 Gone offline. Using cached data.');
          }
        });
  }

  Future<void> _refreshInBackground() async {
    try {
      final users = await _repository
          .getPendingUsers(roomId)
          .then((value) => value.users);
      if (state is RoomApprovalLoaded) {
        emit(
          RoomApprovalLoaded(
            pendingUsers: users,
            isOnline: _connectivityService.isOnline,
          ),
        );
      }
    } catch (e) {
      print('Background refresh failed: $e');
    }
  }

  Future<void> loadPendingUsers() async {
    emit(RoomApprovalLoading());

    try {
      final users = await _repository
          .getPendingUsers(roomId)
          .then((value) => value.users);
      if (users.isEmpty) {
        emit(RoomApprovalEmpty());
      } else {
        emit(
          RoomApprovalLoaded(
            pendingUsers: users,
            isOnline: _connectivityService.isOnline,
          ),
        );
      }
    } catch (e) {
      emit(RoomApprovalError(e.toString()));
    }
  }

  Future<void> approveUser(int userId, String username) async {
    final currentState = state;
    emit(ApprovingUser(userId));

    try {
      await _repository.approveUser(roomId, userId);
      emit(UserApproved(username));

      // Reload the list
      await loadPendingUsers();
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

  Future<void> rejectUser(int userId, String username) async {
    final currentState = state;
    emit(RejectingUser(userId));

    try {
      await _repository.rejectUser(roomId, userId);
      emit(UserRejected(username));

      // Reload the list
      await loadPendingUsers();
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

  Future<void> refreshPendingUsers() async {
    await loadPendingUsers();
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
