import 'dart:convert';

import 'package:chat_app/core/helpers/constants.dart';
import 'package:chat_app/core/helpers/shared_pref_helper.dart';
import 'package:chat_app/core/networking/api_constants.dart';

import '../models/room_model.dart';
import 'package:http/http.dart' as http;
class HomeService {
  String token = SharedPrefHelper.getSecuredString(SharedPrefKeys.userToken) ?? '';
  Future<List<RoomModel>> getRooms() async {
    final response=await http.post(
      Uri.parse(ApiConstants.apiBaseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    try{
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final rooms = data['rooms'];
        return rooms.map((room) => RoomModel.fromJson(room));
      } else {
        throw Exception('Failed to fetch rooms');
      }
    }catch(e){
      throw Exception('Failed to fetch rooms');
    }
    
    
  }


  Future<RoomModel> createRoom(String name, String description, {bool isPrivate = false}) async {
    // Replace with actual API call
    await Future.delayed(const Duration(seconds: 1));
    return RoomModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      room_name: name,
      createdAt: DateTime.now(),
      room_description:description,
      unreadCount: 0,
      is_private: false,
      room_created_by: 1
    );
  }

}