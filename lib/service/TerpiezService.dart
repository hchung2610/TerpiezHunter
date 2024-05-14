import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../redis/RedisService.dart';
import 'ImageService.dart';

class TerpiezService {
  final RedisService redisService;
  final ImageService imageService;

  TerpiezService(this.redisService, this.imageService);

  Future<void> catchAndStoreTerpiez(String terpiezId, double latitude, double longitude) async {
    var details = await redisService.fetchTerpiezDetails(terpiezId);

    String thumbnailPath = await fetchAndSaveImage(details['thumbnail'], 'thumbnail_$terpiezId.png');

    String imagePath = await fetchAndSaveImage(details['image'], 'image_$terpiezId.png');

    Map<String, dynamic> terpiezData = {
      'id': terpiezId,
      'name': details['name'],
      'description': details['description'],
      'thumbnail': thumbnailPath,
      'image': imagePath,
      'stats': details['stats'],
      'latitude': latitude,
      'longitude': longitude,
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('terpiez_$terpiezId', jsonEncode(terpiezData));

  }

  Future<String> fetchAndSaveImage(String key, String fileName) async {
    String imageDataBase64 = await redisService.fetchImageData(key);
    return imageService.decodeAndStoreBase64Image(imageDataBase64, fileName);
  }
}
