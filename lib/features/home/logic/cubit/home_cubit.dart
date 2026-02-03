import 'dart:async';
import 'package:chat_app/core/services/internet_connectivity_service.dart';
import 'package:chat_app/features/home/data/repos/home_repo.dart';
import 'package:chat_app/features/home/logic/cubit/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepositoryWithCache _repository;
  final ConnectivityService _connectivityService;

  StreamSubscription<bool>? _connectivitySubscription;

  HomeCubit(this._repository, this._connectivityService)
    : super(HomeInitial()) {
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
      final rooms = await _repository.getRooms();
      if (state is HomeLoaded) {
        emit(
          HomeLoaded(rooms: rooms, isOffline: !_connectivityService.isOnline),
        );
      }
    } catch (e) {
      print('Background refresh failed: $e');
    }
  }

  Future<void> loadRooms() async {
    emit(HomeLoading());

    try {
      // This will return cached data if offline, or fresh data if online
      final rooms = await _repository.getRooms();
      emit(HomeLoaded(rooms: rooms, isOffline: !_connectivityService.isOnline));
    } catch (e) {
      emit(HomeError(e.toString(), !_connectivityService.isOnline));
    }
  }

  Future<void> createRoom(
    String name,
    String description, {
    bool isPrivate = false,
  }) async {
    if (!_connectivityService.isOnline) {
      emit(
        HomeError(
          'Cannot create room while offline. Please check your connection.',
          !_connectivityService.isOnline,
        ),
      );
      return;
    }

    final currentState = state;
    emit(RoomCreating());

    try {
      final room = await _repository.createRoom(
        name,
        description,
        isPrivate: isPrivate,
      );
      emit(RoomCreated(room));

      // Reload rooms after creation
      await loadRooms();
    } catch (e) {
      if (currentState is HomeLoaded) {
        emit(currentState);
      }
      emit(HomeError(e.toString(), !_connectivityService.isOnline));

      // Restore previous state after showing error
      if (currentState is HomeLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> refreshRooms() async {
    if (!_connectivityService.isOnline) {
      // Just reload from cache
      await loadRooms();
      return;
    }

    await loadRooms();
  }

  Future<void> searchRooms(String query) async {
    if (!_connectivityService.isOnline) {
      emit(
        HomeError(
          'Cannot search rooms while offline. Please check your connection.',
          !_connectivityService.isOnline,
        ),
      );
      return;
    }
    final currentState = state;
    try {
      final rooms = await _repository.searchRooms(query);
      emit(HomeLoaded(rooms: rooms, isOffline: !_connectivityService.isOnline));
    } catch (e) {
      if (currentState is HomeLoaded) {
        emit(currentState);
      }
      emit(HomeError(e.toString(), !_connectivityService.isOnline));

      // Restore previous state after showing error
      if (currentState is HomeLoaded) {
        emit(currentState);
      }
    }
  }

  void logout() {
    emit(HomeInitial());
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
