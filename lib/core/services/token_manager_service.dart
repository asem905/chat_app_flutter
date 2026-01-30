import 'dart:async';
import 'package:chat_app/core/helpers/constants.dart';
import 'package:chat_app/core/helpers/shared_pref_helper.dart';
import 'package:flutter/material.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  Timer? _expirationTimer;
  DateTime? _tokenExpirationTime;
  VoidCallback? _onTokenExpired;

  void initialize(VoidCallback onTokenExpired) {
    _onTokenExpired = onTokenExpired;
  }

  Future<void> saveToken(
    String token, {
    Duration validity = const Duration(days: 3),
  }) async {
    cancelTimer();

    await SharedPrefHelper.setSecuredString(SharedPrefKeys.userToken, token);
    print("token+=+: $token");

    _tokenExpirationTime = DateTime.now().add(validity);
    print(
      "token_expiration+=+: ${_tokenExpirationTime!.millisecondsSinceEpoch}",
    );
    await SharedPrefHelper.setData(
      'token_expiration',
      _tokenExpirationTime!.millisecondsSinceEpoch,
    );

    _startExpirationTimer(validity);

    print("Token saved. Expires at: $_tokenExpirationTime");
  }

  //i can navigate to login screen from any screen when token expires due to global navigator key i passed to main
  void _startExpirationTimer(Duration duration) {
    _expirationTimer = Timer(duration, () async {
      print("Token expired - logging out user");
      await clearToken();
      _onTokenExpired?.call();
    });
  }

  /// Check if token is still valid and restore timer if app was closed
  Future<bool> checkAndRestoreToken() async {
    final token = await SharedPrefHelper.getSecuredString(
      SharedPrefKeys.userToken,
    );

    if (token == null || token.isEmpty) {
      return false;
    }

    final expirationMillis = await SharedPrefHelper.getInt('token_expiration');

    if (expirationMillis == null) {
      await clearToken();
      return false;
    }

    final expirationTime = DateTime.fromMillisecondsSinceEpoch(
      expirationMillis as int,
    );
    final now = DateTime.now();

    if (now.isAfter(expirationTime)) {
      // Token expired
      print("Token already expired");
      await clearToken();
      return false;
    }

    // Token still valid, restart timer with remaining time
    final remainingDuration = expirationTime.difference(now);
    _tokenExpirationTime = expirationTime;
    _startExpirationTimer(remainingDuration);

    print("Token valid. Expires in: ${remainingDuration.inMinutes} minutes");
    return true;
  }

  Future<void> clearToken() async {
    cancelTimer();
    await SharedPrefHelper.clearAllSecuredData();
    await SharedPrefHelper.removeData('token_expiration');
    _tokenExpirationTime = null;
  }

  /// Cancel the expiration timer
  void cancelTimer() {
    _expirationTimer?.cancel();
    _expirationTimer = null;
  }

  /// Get remaining time before token expiration
  Duration? getRemainingTime() {
    if (_tokenExpirationTime == null) return null;
    final remaining = _tokenExpirationTime!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Extend token validity (call after successful API request)
  Future<void> extendToken({
    Duration extension = const Duration(hours: 1),
  }) async {
    if (_tokenExpirationTime == null) return;

    cancelTimer();
    _tokenExpirationTime = DateTime.now().add(extension);
    await SharedPrefHelper.setData(
      'token_expiration',
      _tokenExpirationTime!.millisecondsSinceEpoch,
    );
    _startExpirationTimer(extension);

    print("Token extended. New expiration: $_tokenExpirationTime");
  }

  /// Dispose resources
  void dispose() {
    cancelTimer();
    _onTokenExpired = null;
  }
}
