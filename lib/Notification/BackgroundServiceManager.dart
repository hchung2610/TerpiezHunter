import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Noti.dart';

class BackgroundServiceManager {

  static void initializeBackgroundService() async {
    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
      ),
      iosConfiguration: IosConfiguration(
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }
  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async{

    WidgetsFlutterBinding.ensureInitialized();
    Noti.initialize();
    final prefs = await SharedPreferences.getInstance();

    Timer.periodic(const Duration(seconds: 15), (Timer timer) async {
      prefs.reload();
      double closestDistance = prefs.getDouble('closestDistance') ?? double.infinity;

      print ("check if update: $closestDistance");
      print ("check if update before time: $closestDistance");
      if (closestDistance <= 20) {
        service.invoke("setAsForeground");
        await Noti.showNotification(
            "A Terpiez is near!",
            "Be alert!",
            101,
            closestDistance
        );
      }
    });

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });
    }
  }

  static bool onIosBackground(ServiceInstance service) {
    return true;
  }
}