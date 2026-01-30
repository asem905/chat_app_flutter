import 'package:chat_app/features/home/data/models/available_rooms_model.dart';
import 'package:equatable/equatable.dart';

abstract class DiscoverRoomsState extends Equatable {
  @override
  List<Object> get props => [];
}

class DiscoverRoomsInitial extends DiscoverRoomsState {}

class DiscoverRoomsLoading extends DiscoverRoomsState {}

class DiscoverRoomsLoaded extends DiscoverRoomsState {
  final List<RoomWithMembersModel> rooms;
  final List<RoomWithMembersModel> filteredRooms;
  final String searchQuery;
  final bool isOnline;

  DiscoverRoomsLoaded({
    required this.rooms,
    required this.filteredRooms,
    this.searchQuery = '',
    this.isOnline = false,
  });
  @override
  List<Object> get props => [rooms, filteredRooms, searchQuery, isOnline];
}

class DiscoverRoomsError extends DiscoverRoomsState {
  final String message;
  DiscoverRoomsError(this.message);
  @override
  List<Object> get props => [message];
}

class JoiningRoom extends DiscoverRoomsState {
  final int roomId;
  JoiningRoom(this.roomId);
  @override
  List<Object> get props => [roomId];
}

class RoomJoined extends DiscoverRoomsState {
  final int roomId;
  final String roomName;
  RoomJoined(this.roomId, this.roomName);
  @override
  List<Object> get props => [roomId, roomName];
}

class JoinRoomError extends DiscoverRoomsState {
  final String message;
  JoinRoomError(this.message);
  @override
  List<Object> get props => [message];
}
