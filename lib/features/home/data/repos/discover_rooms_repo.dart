import 'package:chat_app/core/services/internet_connectivity_service.dart';
import 'package:chat_app/features/home/data/models/available_rooms_model.dart';
import 'package:chat_app/features/home/data/services/discover_rooms_service.dart';

class DiscoverRoomsRepository {
  final DiscoverRoomsService _service;
  final ConnectivityService _connectivityService;
  DiscoverRoomsRepository(this._service, this._connectivityService);

  Future<AvailableRoomsResponseModel> getAvailableRooms() async {
    if (!_connectivityService.isOnline) {
      return AvailableRoomsResponseModel(availableRooms: [], status: 'success');
    }
    return await _service.getAvailableRooms();
  }

  Future<void> joinRoom(int roomId) async {
    return await _service.joinRoom(roomId);
  }
}
