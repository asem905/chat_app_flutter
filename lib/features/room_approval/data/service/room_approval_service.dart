import 'dart:convert';

import 'package:chat_app/core/helpers/constants.dart';
import 'package:chat_app/core/helpers/shared_pref_helper.dart';
import 'package:chat_app/core/networking/api_constants.dart';
import 'package:chat_app/features/room_approval/data/models/pendimg_user_model.dart';

import 'package:http/http.dart' as http;

class RoomApprovalService {
  final String token;
  RoomApprovalService(this.token);
  static create() async {
    final token =
        await SharedPrefHelper.getSecuredString(SharedPrefKeys.userToken) ?? '';
    return RoomApprovalService(token);
  }

  Future<PendingUserModel> getPendingUsers(int roomId) async {
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
        print("pending users:$data");
        return PendingUserModel.fromJson(data);
      } else {
        throw Exception('Failed to fetch pending users');
      }
    } catch (e) {
      print(e.toString());
      throw Exception('Failed to fetch pending users');
    }
  }

  Future<void> approveUser(int roomId, int userId) async {
    final response = await http.post(
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
    // Replace with actual API call
    // await _dio.post('/api/rooms/$roomId/reject-user/$userId');
    // OR
    // await _dio.delete('/api/rooms/$roomId/users/$userId');

    // Simulated response
    await Future.delayed(const Duration(milliseconds: 800));
    // Success - no return needed
  }
}
