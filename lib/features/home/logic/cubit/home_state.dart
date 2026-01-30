import 'package:equatable/equatable.dart';
import '../../data/models/room_model.dart';

abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<RoomModel> rooms;
  final bool isOffline; // ✅ NEW

  HomeLoaded({
    required this.rooms,
    this.isOffline = false, // ✅ NEW
  });

  @override
  List<Object?> get props => [rooms, isOffline];
}

class HomeError extends HomeState {
  final String message;
  final bool isOffline;
  HomeError(this.message, this.isOffline);

  @override
  List<Object?> get props => [message, isOffline];
}

class RoomLoading extends HomeState {}

class RoomCreating extends HomeState {}

class GetRooms extends HomeState {
  final List<RoomModel> rooms;
  GetRooms(this.rooms);

  @override
  List<Object?> get props => [rooms];
}

class RoomCreated extends HomeState {
  final RoomModel room;
  RoomCreated(this.room);

  @override
  List<Object?> get props => [room];
}
