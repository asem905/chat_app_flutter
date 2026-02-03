import 'dart:convert';
import 'package:chat_app/core/helpers/get_token.dart';
import 'package:chat_app/core/networking/api_constants.dart';
import '../models/room_model.dart';
import 'package:http/http.dart' as http;

class HomeService {
  // Private constructor
  HomeService();

  // Factory method to create instance asynchronously

  Future<List<RoomModel>> getRooms() async {
    try {
      final result = await getTokenAndCurrentUserId();
      print("result: $result");
      final token = result['token'];
      print('📡 Fetching rooms from: ${ApiConstants.myRooms}');
      print(
        '🔑 Token: ${token.isEmpty ? "EMPTY TOKEN!" : "Token === $token === exists"}',
      );

      final response = await http.get(
        Uri.parse(ApiConstants.myRooms),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      // Check status code first
      if (response.statusCode != 200) {
        throw Exception(
          'Server error: ${response.statusCode} - ${response.body}',
        );
      }

      final res = json.decode(response.body);

      print('✅ Response Status: ${res["status"]}');

      if (res["status"] == "SUCCESS") {
        final data = res["data"];

        // Add null check
        if (data == null) {
          throw Exception('Data is null in response');
        }

        final rooms = data["rooms"];

        // Add null and type checks
        if (rooms == null) {
          print('⚠️ No rooms found, returning empty list');
          return [];
        }

        if (rooms is! List) {
          throw Exception('Rooms is not a list: ${rooms.runtimeType}');
        }

        print('📦 Found ${rooms.length} rooms');

        // Cast to List and map
        return (rooms).map((room) => RoomModel.fromJson(room)).toList();
      } else {
        final message = res["message"] ?? "Unknown error";
        throw Exception('API Error: $message');
      }
    } catch (e) {
      print('❌ Error in getRooms: $e');
      rethrow; // Rethrow to let Cubit handle it
    }
  }

  // ==================== CREATE ROOM ====================

  Future<RoomModel> createRoom(
    String name,
    String description, {
    bool isPrivate = false,
  }) async {
    try {
      print('📡 Creating room: $name');
      final result = await getTokenAndCurrentUserId();
      final token = result['token'];
      final response = await http.post(
        Uri.parse(ApiConstants.createRoom), // Add this to your ApiConstants
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'room_name': name,
          'room_description': description,
          'is_private': isPrivate,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = json.decode(response.body);

        if (res["status"] == "SUCCESS") {
          print('✅ Room created successfully');
          final roomData = res["data"]["room"];
          return RoomModel.fromJson(roomData);
        } else {
          throw Exception('Failed to create room: ${res["message"]}');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in createRoom: $e');
      rethrow;
    }
  }

  // ==================== SEARCH ROOMS ====================

  Future<List<RoomModel>> searchRooms(String query) async {
    try {
      print('🔍 Searching for rooms: $query');
      final result = await getTokenAndCurrentUserId();
      final token = result['token'];
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.searchRooms}?name=$query',
        ), // Add this to your ApiConstants
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final res = json.decode(response.body);

        if (res["status"] == "SUCCESS") {
          final rooms = res["data"]["rooms"];
          return (rooms as List)
              .map((room) => RoomModel.fromJson(room))
              .toList();
        } else {
          throw Exception('Failed to search rooms: ${res["message"]}');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in searchRooms: $e');
      rethrow;
    }
  }
}
