import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConstants {
  // Default fallback IP (your current computer)
  static const String _defaultIp = "192.168.1.13";
  static const String _port = "3001";
  static const String _productionUrl = "https://your-production-api.com";
  
  // Dynamic base URL - will be set after discovery
  static String _baseUrl = "http://$_defaultIp:$_port";
  static String _apiBaseUrl = "http://$_defaultIp:$_port/api/v1";
  
  // Public getters for URLs
  static String get baseUrl => _baseUrl;
  static String get apiBaseUrl => _apiBaseUrl;
  
  // API Endpoints
  static String get login => "$apiBaseUrl/users/login";
  static String get signUp => "$apiBaseUrl/users/register";
  static String get rooms => "$apiBaseUrl/rooms";
  static String get myRooms => "$rooms/";
  static String get getAllRooms => "$rooms/all-rooms";
  static String get createRoom => "$rooms/create";
  
  /// Initialize API - discovers server or uses cached/manual IP
  static Future<bool> initialize() async {
    if (kReleaseMode) {
      _setUrls(_productionUrl);
      print('🌐 Using production API: $_productionUrl');
      return true;
    }
    
    print('🔍 Initializing API configuration...');
    
    // Step 1: Try cached server URL
    final cachedUrl = await _getCachedServerUrl();
    if (cachedUrl != null && await _testConnection(cachedUrl)) {
      _setUrls(cachedUrl);
      print('✅ Using cached server: $cachedUrl');
      return true;
    }
    
    // Step 2: Try default IP
    final defaultUrl = "http://$_defaultIp:$_port";
    if (await _testConnection(defaultUrl)) {
      _setUrls(defaultUrl);
      await _cacheServerUrl(defaultUrl);
      print('✅ Using default server: $defaultUrl');
      return true;
    }
    
    // Step 3: Auto-discover server on network
    print('🔍 Auto-discovering server on network...');
    final discoveredUrl = await _discoverServer();
    if (discoveredUrl != null) {
      _setUrls(discoveredUrl);
      await _cacheServerUrl(discoveredUrl);
      print('✅ Server discovered: $discoveredUrl');
      return true;
    }
    
    // Step 4: Failed - use default and let user configure manually
    _setUrls(defaultUrl);
    print('⚠️ Could not find server, using default: $defaultUrl');
    return false;
  }
  
  /// Manually set server IP (for settings screen)
  static Future<void> setServerIp(String ip) async {
    final url = "http://$ip:$_port";
    if (await _testConnection(url)) {
      _setUrls(url);
      await _cacheServerUrl(url);
      print('✅ Server IP updated: $url');
    } else {
      throw Exception('Cannot connect to server at $ip');
    }
  }
  
  /// Test if current server is reachable
  static Future<bool> testCurrentServer() async {
    return await _testConnection(_baseUrl);
  }
  
  /// Get current server IP
  static String getCurrentServerIp() {
    final uri = Uri.parse(_baseUrl);
    return uri.host;
  }
  
  // ========== Private Helper Methods ==========
  
  static void _setUrls(String baseUrl) {
    _baseUrl = baseUrl;
    _apiBaseUrl = "$baseUrl/api/v1";
  }
  
  static Future<String?> _getCachedServerUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('cached_server_url');
    } catch (e) {
      return null;
    }
  }
  
  static Future<void> _cacheServerUrl(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_server_url', url);
    } catch (e) {
      print('Failed to cache server URL: $e');
    }
  }
  
  static Future<bool> _testConnection(String baseUrl) async {
    try {
      final uri = Uri.parse('$baseUrl/api/v1/rooms');
      final client = HttpClient();
      final request = await client.getUrl(uri).timeout(
        Duration(seconds: 3),
      );
      final response = await request.close();
      client.close();
      
      // Accept 200 (success), 401 (needs auth), or 404 (endpoint exists)
      return response.statusCode == 200 || 
             response.statusCode == 401 || 
             response.statusCode == 404;
    } catch (e) {
      return false;
    }
  }
  
  static Future<String?> _discoverServer() async {
    try {
      // Get local IP to determine subnet
      final localIp = await _getLocalIpAddress();
      if (localIp == null) return null;
      
      // Extract subnet (e.g., 192.168.1.x -> 192.168.1)
      final subnet = localIp.substring(0, localIp.lastIndexOf('.'));
      print('📡 Scanning subnet: $subnet.x');
      
      // Scan IP range in parallel (limit to avoid overwhelming network)
      final futures = <Future<String?>>[];
      for (int i = 1; i < 255; i++) {
        final ip = '$subnet.$i';
        if (ip != localIp) {
          futures.add(_testServerIp(ip));
        }
        
        // Process in batches of 50 to avoid too many concurrent connections
        if (futures.length >= 50) {
          final results = await Future.wait(futures);
          final found = results.firstWhere((ip) => ip != null, orElse: () => null);
          if (found != null) return "http://$found:$_port";
          futures.clear();
        }
      }
      
      // Check remaining
      if (futures.isNotEmpty) {
        final results = await Future.wait(futures);
        final found = results.firstWhere((ip) => ip != null, orElse: () => null);
        if (found != null) return "http://$found:$_port";
      }
      
      return null;
    } catch (e) {
      print('Discovery error: $e');
      return null;
    }
  }
  
  static Future<String?> _testServerIp(String ip) async {
    try {
      // Quick socket test first
      final socket = await Socket.connect(
        ip,
        int.parse(_port),
        timeout: Duration(milliseconds: 300),
      );
      socket.destroy();
      
      // Verify it's our server
      if (await _testConnection("http://$ip:$_port")) {
        return ip;
      }
    } catch (e) {
      // Expected for most IPs
    }
    return null;
  }
  
  static Future<String?> _getLocalIpAddress() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );
      
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          final ip = addr.address;
          if (ip.startsWith('192.168.') || 
              ip.startsWith('10.') || 
              ip.startsWith('172.')) {
            return ip;
          }
        }
      }
    } catch (e) {
      print('Error getting local IP: $e');
    }
    return null;
  }
}