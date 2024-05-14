import 'dart:async';
import 'dart:convert';
import 'package:redis/redis.dart';
import '../service/SecureStorageService.dart';

class RedisService {
  final RedisConnection _conn = RedisConnection();
  final SecureStorageService _storage = SecureStorageService();
  bool _connectionSuccessful = true;
  final _connectionController = StreamController<bool>.broadcast();

  Stream<bool> get onConnectionChange => _connectionController.stream;

  Future<Command> connectAndLogin() async {
    try {
      final credentials = await _storage.getCredentials();
      Command command = await _conn.connect(
        'cmsc436-0101-redis.cs.umd.edu',
        6380,
      ).timeout(const Duration(seconds: 10));
      var authResponse = await command.send_object(['AUTH', credentials['username'], credentials['password']]);
      if (authResponse.toString().contains('OK')) {
        print('Redis authentication successful');
        _setConnectionSuccessful(true);
        return command;
      } else {
        print('Redis authentication failed: $authResponse');
        _setConnectionSuccessful(false);
        throw Exception('Failed to authenticate with Redis server.');
      }
    } catch (e) {
      print('Error connecting to Redis: $e');
      _setConnectionSuccessful(false);
      throw Exception('Failed to connect and authenticate with Redis server.');
    }
  }
  void _setConnectionSuccessful(bool status) {
    if (_connectionSuccessful != status) {
      _connectionSuccessful = status;
      _connectionController.add(status);
    }
  }
  bool get isConnectionSuccessful => _connectionSuccessful;

  void dispose() {
    _connectionController.close();
  }

  Future<void> resetTerpiezData() async {
    try {
      final credentials = await _storage.getCredentials();
      Command command = await connectAndLogin();
      await command.send_object(['JSON.SET', credentials['username'], '.', '{}']);
      print('Terpiez data reset successfully ${credentials['username']}');
    } catch (e) {
      print('Failed to reset Terpiez data: $e');
      throw Exception('Failed to reset Terpiez data.');
    }
  }

  Future<bool> testConnection() async {
    try {
      await connectAndLogin();
      return true;  // Connection successful
    } catch (e) {
      print('Connection test failed: $e');
      return false;  // Connection failed
    }
  }

  Future<void> reconnect() async {
    print("Attempting to reconnect...");
    try {
      await connectAndLogin();
      print("Reconnection successful.");
    } catch (e) {
      print("Reconnection failed: $e");
    }
  }

  Future<List<dynamic>?> fetchTerpiezLocations() async {
    try {
      final command = await connectAndLogin();
      final response = await command.send_object(['JSON.GET', 'locations']);
      if (response != null) {
        print('Fetched locations: $response');
        return jsonDecode(response);
      } else {
        print('No locations found in Redis. Response was null.');
        return null;
      }
    } catch (e) {
      print("Error fetching Terpiez locations: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>> fetchTerpiezDetails(String terpiezId) async {
    final command = await connectAndLogin();
    final response = await command.send_object(['JSON.GET', 'terpiez', terpiezId]);
    if (response != null) {
      return jsonDecode(response);
    } else {
      throw Exception('Terpiez details not found for ID: $terpiezId');
    }
  }

  Future<String> fetchImageData(String key) async {
    final command = await connectAndLogin();
    final response = await command.send_object(['JSON.GET', 'images', key]);
    if (response != null) {
      return jsonDecode(response);
    } else {
      throw Exception('Image data not found for key: $key');
    }
  }

  Future<bool> validateCredentials(Map<String, String> credentials) async {
    try {
      Command command = await _conn.connect('cmsc436-0101-redis.cs.umd.edu', 6380);
      var authResponse = await command.send_object(['AUTH', credentials['username'], credentials['password']]);
      return authResponse.toString().contains('OK');
    } catch (e) {
      print('Validation failed: $e');
      return false;
    }
  }
  bool get isConnected => _connectionSuccessful;
}