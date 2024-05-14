import 'package:flutter/material.dart';
import '../redis/RedisConnectivityService.dart';
import '../redis/RedisService.dart';
import '../service/PreferencesService.dart';
import 'homePage.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  late PreferencesService preferencesService;
  late RedisService redisService;
  late RedisConnectivityService connectivityService;

  @override
  void initState() {
    super.initState();
    redisService = RedisService();
    preferencesService = PreferencesService();
    connectivityService = RedisConnectivityService(redisService, scaffoldMessengerKey);
    connectivityService.startMonitoring();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      redisService.testConnection().then((connected) {
        if (!connected) {
          redisService.reconnect();
        }
      });
    });
  }

  @override
  void dispose() {
    connectivityService.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      navigatorKey: MyApp.navigatorKey,
      title: 'Terpiez',
      theme: ThemeData(
        iconTheme: const IconThemeData(color :Colors.black), //setting black for every icon
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            color: Colors.white, // Title text color
            fontSize: 20, //
          ),
          backgroundColor: Colors.red,
          iconTheme: IconThemeData(color: Colors.white70),
        ),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Terpiez', preferencesService: preferencesService),
      routes: {
        '/Finder': (context) => MyHomePage(
            title: 'Terpiez',
            selectedTab: 1,
            preferencesService: preferencesService
        ),
      },
    );
  }
}
