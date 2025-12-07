import 'dart:convert';
import 'package:chat_app/core/helpers/get_token.dart';
import 'package:chat_app/core/networking/api_constants.dart';
import 'package:chat_app/features/home/data/models/available_rooms_model.dart';
import 'package:http/http.dart' as http;

class DiscoverRoomsService {
  // final Dio _dio;
  DiscoverRoomsService();

  Future<AvailableRoomsResponseModel> getAvailableRooms() async {
    // Replace with actual API call
    final result = await getTokenAndCurrentUserId();
    final token = result['token'];
    final response = await http.get(
      Uri.parse(ApiConstants.getAllRooms),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        "Authorization": "Bearer $token",
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print("available rooms:$data");
      return AvailableRoomsResponseModel.fromJson(data);
    } else {
      throw Exception('Failed to fetch available rooms');
    }
  }

  Future<void> joinRoom(int roomId) async {
    // Replace with actual API call
    // await _dio.post('/api/rooms/$roomId/join');

    // Simulated response
    await Future.delayed(const Duration(seconds: 1));
    // Success - no return needed
  }
}
