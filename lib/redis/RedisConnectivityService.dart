import 'dart:async';
import 'package:flutter/material.dart';
import 'RedisService.dart';

class RedisConnectivityService {
  final RedisService _redisService;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  bool _isConnected = false;
  Timer? _connectivityTimer;

  RedisConnectivityService(this._redisService, this.scaffoldMessengerKey);

  void startMonitoring() {
    _connectivityTimer?.cancel();
    _connectivityTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      bool result = await _redisService.testConnection();
      if (_isConnected != result) {
        _isConnected = result;
        _notifyConnectionChange(result);
      }
    });
  }

  void _notifyConnectionChange(bool isConnected) {
    final snackBar = SnackBar(
      content: Text(
        isConnected ? "Connection to server restored" : "Lost connection to Redis server",
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: isConnected ? Colors.green : Colors.red,
    );
    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  void stopMonitoring() {
    _connectivityTimer?.cancel();
  }
}
