import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CaughtTerpiezProvider with ChangeNotifier {
  List<Map<String, dynamic>> _caughtTerpiez = [];

  List<Map<String, dynamic>> get caughtTerpiez => _caughtTerpiez;

  Future<void> loadCaughtTerpiez() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('terpiez_')).toList();

    List<Map<String, dynamic>> tempList = [];
    for (var key in keys) {
      final jsonString = prefs.getString(key);
      if (jsonString != null) {
        Map<String, dynamic> terpiezData = jsonDecode(jsonString);
        print(terpiezData);
        tempList.add(terpiezData);
      }
    }

    _caughtTerpiez = tempList;
    notifyListeners();
  }
}
