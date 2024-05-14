import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class UserIdProvider with ChangeNotifier {
  String _userId = '';

  UserIdProvider() {
    _loadUserId();
  }
  String get userId => _userId;

  Future<void> _loadUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? fetchedUserId = prefs.getString('userId');
    print("Fetched user ID: $fetchedUserId");

    if (fetchedUserId == null) {
      print("User ID not found, generating a new one.");
      fetchedUserId = const Uuid().v4();
      await prefs.setString('userId', fetchedUserId);
    }

    _userId = fetchedUserId;
    notifyListeners();
  }

  Future<String> getUserId() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('userId') ?? '';

      if (userId.isEmpty) {
        userId = const Uuid().v4();
        await prefs.setString('userId', userId);
        _userId = userId;
        notifyListeners();
      }

      return userId;
    } catch (e) {
      print("Failed to load user ID: $e");
      return _userId;
    }
  }
  Future<void> regenerateUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = const Uuid().v4();
    await prefs.setString('userId', _userId);
    notifyListeners();
  }
}
