import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../mainTab/myApp.dart';

class Noti {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  static Future<void> initialize() async {
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: handleBackgroundNotificationResponse,
    );
  }

  static void handleNotificationResponse(NotificationResponse response) {
    debugPrint('Notification action taken by the user in the foreground: ${response.payload}');
    MyApp.navigatorKey.currentState?.pushNamed('/Finder');
  }

  static void handleBackgroundNotificationResponse(NotificationResponse response) {
    debugPrint('Notification action taken by the user in background: ${response.payload}');
  }

  static Future<void> showNotification(String title, String body, int id, double distance) async {
    String formattedDistance = "${distance.toStringAsFixed(0)}m";
    String fullBody = '$body It\'s $formattedDistance away! Catch it before it escapes!';

    var androidDetails = const AndroidNotificationDetails(
      'channelId',
      'channelName',
      channelDescription: 'Notification channel for Terpiez app',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('electronichit'),
      playSound: true,
    );
    var details = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(id, title, fullBody, details);
  }

}