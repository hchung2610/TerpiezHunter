import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ImageService {
  Future<String> downloadImageFromUrl(String url, String filename) async {
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Directory dir = await getApplicationDocumentsDirectory();
      File file = File('${dir.path}/$filename');
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    } else {
      throw Exception('Failed to download image from $url');
    }
  }

  Future<String> decodeAndStoreBase64Image(String base64String, String filename) async {
    Directory dir = await getApplicationDocumentsDirectory();
    File file = File('${dir.path}/$filename');
    List<int> imageBytes = base64Decode(base64String);
    await file.writeAsBytes(imageBytes);
    return file.path;
  }
}
