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

    _tokenExpirationTime = DateTime.now().add(validity);
    await SharedPrefHelper.setData(
      'token_expiration',
      _tokenExpirationTime!.millisecondsSinceEpoch,
    );

    _startExpirationTimer(validity);
  }

  void _startExpirationTimer(Duration duration) {
    _expirationTimer = Timer(duration, () async {
      await clearToken();
      _onTokenExpired?.call();
    });
  }

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
      await clearToken();
      return false;
    }

    final remainingDuration = expirationTime.difference(now);
    _tokenExpirationTime = expirationTime;
    _startExpirationTimer(remainingDuration);

    return true;
  }

  Future<void> clearToken() async {
    cancelTimer();
    await SharedPrefHelper.clearAllSecuredData();
    await SharedPrefHelper.removeData('token_expiration');
    _tokenExpirationTime = null;
  }

  void cancelTimer() {
    _expirationTimer?.cancel();
    _expirationTimer = null;
  }

  Duration? getRemainingTime() {
    if (_tokenExpirationTime == null) return null;
    final remaining = _tokenExpirationTime!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

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
  }

  void dispose() {
    cancelTimer();
    _onTokenExpired = null;
  }
}
