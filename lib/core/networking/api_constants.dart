class ApiConstants {
  static const String apiBaseUrl = "http://192.168.1.13:3000/api/v1";

  static const String login = "$apiBaseUrl/users/login";
  static const String signUp = "$apiBaseUrl/users/register";
  static const String rooms= "$apiBaseUrl/rooms";
  static const String myRooms= "$rooms/";
  static const String getAllRooms= "$rooms/all-rooms";//for only admin
  static const String createRoom= "$rooms/create";
}
