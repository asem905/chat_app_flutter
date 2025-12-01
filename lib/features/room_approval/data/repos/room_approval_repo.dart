import 'package:chat_app/features/room_approval/data/models/pendimg_user_model.dart';
import 'package:chat_app/features/room_approval/data/service/room_approval_service.dart';


class RoomApprovalRepository {
  final RoomApprovalService _service;

  RoomApprovalRepository(this._service);

  Future<PendingUserModel> getPendingUsers(int roomId) async {
    return await _service.getPendingUsers(roomId);
  }

  Future<void> approveUser(int roomId, int userId) async {
    return await _service.approveUser(roomId, userId);
  }

  Future<void> rejectUser(int roomId, int userId) async {
    return await _service.rejectUser(roomId, userId);
  }
}