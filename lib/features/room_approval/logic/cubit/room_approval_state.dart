import 'package:equatable/equatable.dart';

sealed class RoomApprovalState extends Equatable {
  const RoomApprovalState();

  @override
  List<Object> get props => [];
}
final class RoomApprovalInitial extends RoomApprovalState {}

class RoomApprovalLoading extends RoomApprovalState {}

class RoomApprovalLoaded extends RoomApprovalState {
  final List pendingUsers;

  const RoomApprovalLoaded({
    required this.pendingUsers,
  });
  @override
  List<Object> get props => [pendingUsers];
}

class RoomApprovalEmpty extends RoomApprovalState {}

class RoomApprovalError extends RoomApprovalState {
  final String message;
  const RoomApprovalError(this.message);
  @override
  List<Object> get props => [message];
}

class ApprovingUser extends RoomApprovalState {
  final int userId;
  const ApprovingUser(this.userId);
  @override
  List<Object> get props => [userId];
}

class UserApproved extends RoomApprovalState {
  final String username;
  const UserApproved(this.username);
  @override
  List<Object> get props => [username];
}

class RejectingUser extends RoomApprovalState {
  final int userId;
  const RejectingUser(this.userId);
  @override
  List<Object> get props => [userId];
}

class UserRejected extends RoomApprovalState {
  final String username;
  const UserRejected(this.username);
  @override
  List<Object> get props => [username];
}

class ApprovalActionError extends RoomApprovalState {
  final String message;
  const ApprovalActionError(this.message);
  @override
  List<Object> get props => [message];
}