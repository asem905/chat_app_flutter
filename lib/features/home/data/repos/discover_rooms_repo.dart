import 'package:chat_app/features/home/data/models/available_rooms_model.dart';
import 'package:chat_app/features/home/data/services/discover_rooms_service.dart';


class DiscoverRoomsRepository {
  final DiscoverRoomsService _service;

  DiscoverRoomsRepository(this._service);

  Future<AvailableRoomsResponseModel> getAvailableRooms() async {
    return await _service.getAvailableRooms();
  }

  Future<void> joinRoom(int roomId) async {
    return await _service.joinRoom(roomId);
  }
}
