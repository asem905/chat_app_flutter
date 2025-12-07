import 'package:chat_app/features/home/data/models/available_rooms_model.dart';
import 'package:chat_app/features/home/data/repos/discover_rooms_repo.dart';
import 'package:chat_app/features/home/logic/cubit/discover_rooms_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiscoverRoomsCubit extends Cubit<DiscoverRoomsState> {
  final DiscoverRoomsRepository _repository;

  DiscoverRoomsCubit(this._repository) : super(DiscoverRoomsInitial());

  Future<void> loadAvailableRooms() async {
    emit(DiscoverRoomsLoading());
    
    try {
      final allrooms = await _repository.getAvailableRooms();
      print("Rooms: ${allrooms.availableRooms}");
      var rooms=allrooms.availableRooms;
      if(rooms.isNotEmpty){
        rooms = rooms.map((room) => RoomWithMembersModel.fromJson(
        room.toJson(),
        )).toList();
        print("Rooms: ${rooms[0].room_owner}");
      }else{
        rooms = [];
      }
      emit(DiscoverRoomsLoaded(
        rooms: rooms,
        filteredRooms: rooms,
      ));
    } catch (e) {
      emit(DiscoverRoomsError(e.toString()));
    }
  }

  void searchRooms(String query) {
    final currentState = state;
    if (currentState is DiscoverRoomsLoaded) {
      if (query.isEmpty) {
        emit(DiscoverRoomsLoaded(
          rooms: currentState.rooms,
          filteredRooms: currentState.rooms,
          searchQuery: query,
        ));
      } else {
        List<RoomWithMembersModel> filtered = [];
        for( var room in currentState.rooms) {
          if(room.room_name.toLowerCase().contains(query.toLowerCase())) {
            filtered.add(room);
          }
        }
        emit(DiscoverRoomsLoaded(
          rooms: currentState.rooms,
          filteredRooms: filtered,
          searchQuery: query,
        ));
      }
    }
  }

  Future<void> joinRoom(int roomId, String roomName) async {
    final currentState = state;
    emit(JoiningRoom(roomId));
    
    try {
      await _repository.joinRoom(roomId);
      emit(RoomJoined(roomId, roomName));
      
      // Reload rooms to update joined status
      await loadAvailableRooms();
    } catch (e) {
      if (currentState is DiscoverRoomsLoaded) {
        emit(currentState);
      }
      emit(JoinRoomError(e.toString()));
      
      // Return to previous state after showing error
      if (currentState is DiscoverRoomsLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> refreshRooms() async {
    await loadAvailableRooms();
  }
}