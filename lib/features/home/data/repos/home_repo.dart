import 'package:chat_app/core/database/chat_database.dart';
import 'package:chat_app/core/services/internet_connectivity_service.dart';
import 'package:chat_app/features/home/data/models/room_model.dart';
import 'package:chat_app/features/home/data/services/home_service.dart';

class HomeRepositoryWithCache {
  final HomeService _service;
  final ChatDatabase _database;
  final ConnectivityService _connectivityService;

  HomeRepositoryWithCache({
    required HomeService service,
    required ChatDatabase database,
    required ConnectivityService connectivityService,
  })  : _service = service,
        _database = database,
        _connectivityService = connectivityService;

  // ==================== GET ROOMS ====================
  
  Future<List<RoomModel>> getRooms() async {
    // Always return cached data first
    final cachedRooms = await _getCachedRooms();
    
    // If online, fetch fresh data and update cache
    if (_connectivityService.isOnline) {
      try {
        final freshRooms = await _service.getRooms();
        
        // Update cache
        await _updateRoomsCache(freshRooms);
        
        return freshRooms;
      } catch (e) {
        print('Failed to fetch fresh rooms, using cache: $e');
        // Return cached data if network call fails
        return cachedRooms;
      }
    }
    
    // If offline, return cached data
    return cachedRooms;
  }

  Future<List<RoomModel>> _getCachedRooms() async {
    final cachedData = await _database.getRooms();
    
    return cachedData.map((data) {
      return RoomModel.fromJson(data);
    }).toList();
  }

  Future<void> _updateRoomsCache(List<RoomModel> rooms) async {
    if (rooms.isEmpty) return;
    
    final roomMaps = rooms.map((room) => room.toJson()).toList();
    await _database.insertRooms(roomMaps);
  }

  // ==================== CREATE ROOM ====================
  
  Future<RoomModel> createRoom(
    String name,
    String description, {
    bool isPrivate = false,
  }) async {
    if (!_connectivityService.isOnline) {
      throw Exception('Cannot create room while offline. Please check your connection.');
    }

    try {
      // Create room on server
      final room = await _service.createRoom(name, description, isPrivate: isPrivate);
      
      // Cache the new room
      await _database.insertRoom(room.toJson());
      
      return room;
    } catch (e) {
      print('Failed to create room: $e');
      rethrow;
    }
  }

  // ==================== UPDATE UNREAD COUNT ====================
  
  Future<void> updateUnreadCount(int roomId, int unreadCount) async {
    await _database.updateRoomUnreadCount(roomId, unreadCount);
  }

  // ==================== DELETE ROOM ====================
  
  Future<void> deleteRoom(int roomId) async {
    // Delete from cache immediately
    await _database.deleteRoom(roomId);
    
    // If online, delete from server
    if (_connectivityService.isOnline) {
      try {
        // Implement server deletion if your API supports it
        // await _service.deleteRoom(roomId);
      } catch (e) {
        print('Failed to delete room from server: $e');
      }
    }
  }

  // ==================== CLEAR CACHE ====================
  
  Future<void> clearCache() async {
    final db = await _database.database;
    await db.delete('rooms');
  }
}