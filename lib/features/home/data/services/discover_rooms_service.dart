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
    print("token succ ftch:$token");
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
    final result = await getTokenAndCurrentUserId();
    final token = result['token'];
    final response = await http.get(
      Uri.parse("${ApiConstants.rooms}/$roomId/join"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        "Authorization": "Bearer $token",
      },
    );
    if (response.statusCode == 200) {
      // Success - no return needed
    } else {
      throw Exception('Failed to join room');
    }
  }
}
