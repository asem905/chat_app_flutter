import 'dart:convert';
import 'package:chat_app/core/helpers/get_token.dart';
import 'package:chat_app/core/networking/api_constants.dart';
import 'package:chat_app/features/room_approval/data/models/pendimg_user_model.dart';

import 'package:http/http.dart' as http;

class RoomApprovalService {
  RoomApprovalService();

  Future<PendingUserModel> getPendingUsers(int roomId) async {
    final result = await getTokenAndCurrentUserId();
    final token = result['token'];
    final response = await http.get(
      Uri.parse("${ApiConstants.rooms}/$roomId/non-approved-users"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    try {
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body)['data'];
        return PendingUserModel.fromJson(data);
      } else {
        throw Exception('Failed to fetch pending users');
      }
    } catch (e) {
      throw Exception('Failed to fetch pending users');
    }
  }

  Future<void> approveUser(int roomId, int userId) async {
    final result = await getTokenAndCurrentUserId();
    final token = result['token'];
    final response = await http.get(
      Uri.parse("${ApiConstants.rooms}/$roomId/approve/$userId"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    try {
      if (response.statusCode == 200) {
        // Success - no return needed
      } else {
        throw Exception('Failed to approve user');
      }
    } catch (e) {
      throw Exception('Failed to approve user');
    }
  }

  Future<void> rejectUser(int roomId, int userId) async {
    final result = await getTokenAndCurrentUserId();
    final token = result['token'];
    final response = await http.get(
      Uri.parse("${ApiConstants.rooms}/$roomId/reject-user/$userId"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    try {
      if (response.statusCode == 200) {
        // Success - no return needed
      } else {
        throw Exception('Failed to reject user');
      }
    } catch (e) {
      throw Exception('Failed to reject user');
    }
  }
}
