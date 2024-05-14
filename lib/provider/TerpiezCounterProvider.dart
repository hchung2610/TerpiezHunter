import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TerpiezCounterProvider with ChangeNotifier {
  int _terpiezCaught = 0;
  DateTime _firstLaunchDate = DateTime.now();

  TerpiezCounterProvider() {
    _loadTerpiezData();
  }

  int get terpiezCaught => _terpiezCaught;
  int get activeDays => DateTime.now().difference(_firstLaunchDate).inDays;

  Future<void> _loadTerpiezData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _terpiezCaught = prefs.getInt('terpiezCaught') ?? 0;

    String? storedDate = prefs.getString('firstLaunchDate');
    if (storedDate != null) {
      _firstLaunchDate = DateTime.parse(storedDate);
    } else {
      await prefs.setString('firstLaunchDate', _firstLaunchDate.toIso8601String());
    }

    notifyListeners();
  }

  Future<void> catchTerpiez() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _terpiezCaught++;
    await prefs.setInt('terpiezCaught', _terpiezCaught);
    notifyListeners();
  }

  Future<void> resetTerpiezCount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _terpiezCaught = 0;
    _firstLaunchDate = DateTime.now();
    await prefs.setInt('terpiezCaught', _terpiezCaught);
    await prefs.setString('firstLaunchDate', _firstLaunchDate.toIso8601String());
    notifyListeners();
  }
}
