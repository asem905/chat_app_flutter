import '../models/room_model.dart';
import '../services/home_service.dart';

class HomeRepository {
  final HomeService _service;

  HomeRepository(this._service);

  Future<List<RoomModel>> getRooms() async {
    return await _service.getRooms();
  }

  Future<RoomModel> createRoom(String name, String description, {bool isPrivate = false}) async {
    return await _service.createRoom(name, description, isPrivate: isPrivate);
  }

}