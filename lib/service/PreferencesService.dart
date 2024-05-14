import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../provider/TerpiezCounterProvider.dart';
import '../provider/TerpiezLocationProvider.dart';
import '../redis/RedisService.dart';

class PreferencesService {
  Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('soundEnabled') ?? true; // default to true
  }

  Future<void> setSoundEnabled(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', isEnabled);
  }

  Future<void> resetLocationData(BuildContext context) async {
    final terpiezLocationProvider = Provider.of<TerpiezLocationProvider>(
        context,
        listen: false
    );
    terpiezLocationProvider.resetLocations();
  }

  Future<void> clearSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    RedisService redisService = RedisService();
    TerpiezCounterProvider terpiezCounterProvider = TerpiezCounterProvider();

    await prefs.clear();
    await prefs.remove('userId');
    await prefs.remove('terpiezCaught');
    await prefs.remove('firstLaunchDate');
    try {
      await  terpiezCounterProvider.resetTerpiezCount();
    } catch (e) {
      throw Exception('Failed to reset Day/Terpiez num.');
    }

    try {
      await redisService.resetTerpiezData();
    } catch (e) {
      throw Exception('Failed to reset Terpiez data in Redis.');
    }

    Set<String> keys = prefs.getKeys();
    for (String key in keys) {
      if (key.startsWith('terpiez_')) {
        await prefs.remove(key);
      }
    }
    await prefs.setString('userId', Uuid().v4());
  }
}