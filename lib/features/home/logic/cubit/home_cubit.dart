import 'package:chat_app/features/home/data/repos/home_repo.dart';
import 'package:chat_app/features/home/logic/cubit/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _repository;

  HomeCubit(this._repository) : super(HomeInitial());

  Future<void> loadRooms() async {
    emit(HomeLoading());
    
    try {
      final rooms = await _repository.getRooms();
      emit(HomeLoaded(rooms: rooms));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> createRoom(String name, String description, {bool isPrivate = false}) async {
    final currentState = state;
    emit(RoomCreating());
    
    try {
      final room = await _repository.createRoom(name, description, isPrivate: isPrivate);
      emit(RoomCreated(room));
      
      // Reload rooms after creation
      await loadRooms();
    } catch (e) {
      if (currentState is HomeLoaded) {
        emit(currentState);
      }
      emit(HomeError(e.toString()));
    }
  }

  Future<void> refreshRooms() async {
    await loadRooms();
  }

  void logout() {
    emit(HomeInitial());
  }
}