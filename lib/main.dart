import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terpiez/provider/CaughtTerpiezProvider.dart';
import 'package:terpiez/provider/TerpiezCounterProvider.dart';
import 'package:terpiez/provider/TerpiezLocationProvider.dart';
import 'package:terpiez/provider/UserIdProvider.dart';
import 'package:terpiez/redis/RedisConnectivityService.dart';
import 'package:terpiez/redis/RedisService.dart';
import 'package:terpiez/service/ImageService.dart';
import 'package:terpiez/service/PreferencesService.dart';
import 'package:terpiez/service/SecureStorageService.dart';
import 'package:terpiez/service/TerpiezService.dart';
import 'package:terpiez/sideTab/PreferencesScreen.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shake/shake.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:typed_data';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import '../Notification/Noti.dart';
import 'Notification/BackgroundServiceManager.dart';
import 'login/credentialsCollectorApp.dart';
import 'mainTab/FinderTab/FinderTab.dart';
import 'mainTab/ListTab/ListTab.dart';
import 'mainTab/StatisticsTab/StatisticsTab.dart';
import 'mainTab/homePage.dart';
import 'mainTab/myApp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BackgroundServiceManager.initializeBackgroundService();
  final secureStorage = SecureStorageService();
  Noti.initialize();
  Map<String, String> credentials = await secureStorage.getCredentials();
  if (credentials['username']!.isEmpty || credentials['password']!.isEmpty) {
    runApp(CredentialsCollectorApp());
  } else {
    final valid = await RedisService().validateCredentials(credentials);
    if (valid) {
      runApp(MultiProviderApp());
    } else {
      runApp(CredentialsCollectorApp());
    }
  }
}

class MultiProviderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ButtonStateProvider()),
        Provider<RedisService>(
          create: (_) => RedisService(),
        ),
        Provider<ImageService>(
          create: (_) => ImageService(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserIdProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => TerpiezCounterProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => CaughtTerpiezProvider(),
        ),
        ChangeNotifierProxyProvider2<RedisService, ImageService, TerpiezLocationProvider>(
          create: (context) => TerpiezLocationProvider(
            redisService: context.read<RedisService>(),
            imageService: context.read<ImageService>(),
          ),
          update: (context, redisService, imageService, previous) => TerpiezLocationProvider(
            redisService: redisService,
            imageService: imageService,
          ),
        ),
      ],
      child: MyApp(),
    );
  }
}















