import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  
  final _statusController = StreamController<bool>.broadcast();
  Stream<bool> get onConnectivityChanged => _statusController.stream;
  
  bool _isOnline = true;
  bool get isOnline => _isOnline;
  
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityService() {
    _init();
  }

  void _init() {
    // Check initial status
    _checkConnectivity();
    
    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _updateConnectionStatus(results);
    });
  }

  Future<void> _checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    
    // Check if any result indicates connectivity
    _isOnline = results.any((result) => 
      result != ConnectivityResult.none
    );
    
    // Only emit if status changed
    if (wasOnline != _isOnline) {
      print('📡 Connectivity changed: ${_isOnline ? "ONLINE" : "OFFLINE"}');
      _statusController.add(_isOnline);
    }
  }

  void dispose() {
    _subscription?.cancel();
    _statusController.close();
  }
}