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
}
