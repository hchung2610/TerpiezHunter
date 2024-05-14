import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shake/shake.dart';
import '../../main.dart';
import '../../provider/TerpiezCounterProvider.dart';
import '../../provider/TerpiezLocationProvider.dart';
import '../../service/PreferencesService.dart';

class FinderTab extends StatefulWidget  {
  FinderTab({Key? key}) : super(key: key);

  @override
  _FinderTabState createState() => _FinderTabState();
}
class _FinderTabState extends State<FinderTab> {
  final AudioPlayer audioPlayer = AudioPlayer();
  final PreferencesService _preferencesService = PreferencesService();

  Completer<GoogleMapController> _controller = Completer();
  static CameraPosition _initialPosition = CameraPosition(
    target: LatLng(38.9890705, -76.9358486),
    zoom: 16,
  );
  ShakeDetector? _detector;
  StreamSubscription<Position>? _positionStreamSubscription;
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;
  DateTime? _lastShakeTime;

  @override
  void initState() {
    super.initState();
    //_startListeningLocation();
    _requestPermissionsAndStart();
    _startShakeDetection();
  }

  void _startShakeDetection() {
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      if (event.x.abs() > 10 || event.y.abs() > 10 || event.z.abs() > 10) {
        DateTime now = DateTime.now();
        if (_lastShakeTime == null || now.difference(_lastShakeTime!).inSeconds > 2) {
          _lastShakeTime = now;
          if (Provider.of<TerpiezLocationProvider>(context, listen: false).isTerpiezInRange) {
            _catchTerpiez();
          }
        }
      }
    });
  }

  Future<void> playSound() async {
    try {
      await audioPlayer.setVolume(1.0);
      await audioPlayer.play(AssetSource('sounds/rizzsounds.mp3'));
      print("Sound playing command issued successfully");
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  void _catchTerpiez() async{
    final terpiezProvider = Provider.of<TerpiezLocationProvider>(context, listen: false);
    if (terpiezProvider.isTerpiezInRange && !terpiezProvider.isCatching) {
      bool soundEnable = await _preferencesService.getSoundEnabled();
      if (soundEnable) {
        playSound();
      }
      terpiezProvider.isCatching = true;

      Provider.of<TerpiezCounterProvider>(context, listen: false).catchTerpiez();
      Provider.of<TerpiezLocationProvider>(context, listen: false).catchTerpiez().then((_) {
        if (terpiezProvider.lastCaughtTerpiez != null) {
          _showCatchDialog(terpiezProvider.lastCaughtTerpiez!);
        }
        Provider.of<TerpiezLocationProvider>(context, listen: false).isCatching = false;

      }).catchError((error) {
        Provider.of<TerpiezLocationProvider>(context, listen: false).isCatching = false;
        print("Error catching Terpiez: $error");
      });

      print("Shake detected and Terpiez catch initiated!");
    } else if (Provider.of<TerpiezLocationProvider>(context, listen: false).isCatching) {
      print("Already catching a Terpiez!");
    }
  }
  void _requestPermissionsAndStart() async {
    // Request notification permission
    PermissionStatus notificationStatus = await Permission.notification.status;
    if (!notificationStatus.isGranted) {
      notificationStatus = await Permission.notification.request();
    }

    if (notificationStatus.isGranted) {

      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.locationAlways,
      ].request();

      final locationStatus = statuses[Permission.location];
      if (locationStatus == PermissionStatus.granted || locationStatus == PermissionStatus.limited) {
        final Stream<Position> positionStream = Geolocator.getPositionStream();
        _positionStreamSubscription = positionStream.listen((Position position) {
          _updateMapLocation(position);
        });
      } else if (locationStatus == PermissionStatus.permanentlyDenied) {

        print("Location permission denied permanently. Please enable it from app settings.");
      }
    } else {
      print("Notification permission not granted. This feature requires notification permission to work.");
    }
  }


  /*void _startListeningLocation() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.locationAlways,
    ].request();

    final status = statuses[Permission.location];

    if (status == PermissionStatus.granted || status == PermissionStatus.limited) {
      final Stream<Position> positionStream = Geolocator.getPositionStream();
      _positionStreamSubscription = positionStream.listen((Position position) {
        _updateMapLocation(position);
      });
    } else if (status == PermissionStatus.permanentlyDenied) {
      openAppSettings();
    }
  }*/


  Future<void> _updateMapLocation(Position position) async {
    if (!_controller.isCompleted) {
      print("GoogleMapController is not ready yet.");
      return;
    }

    final GoogleMapController controller = await _controller.future;
    CameraPosition newCameraPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 18,
    );

    controller.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
    Provider.of<TerpiezLocationProvider>(context, listen: false)
        .updateClosestTerpiezDistance(position.latitude, position.longitude);
    Provider.of<TerpiezLocationProvider>(context, listen: false)
        .setUserLocation(position.latitude, position.longitude);
  }
  void _showCatchDialog(Map<String, dynamic> terpiez) {
    String base64Image = terpiez['imageData'];
    Uint8List bytes = base64Decode(base64Image);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.memory(bytes, fit: BoxFit.cover),
                SizedBox(height: 10),
                Text(terpiez['name'],
                    style: const TextStyle(
                      fontSize: 25,
                    )
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text('Caught a Terpiez!',
                      style: TextStyle(
                        fontSize: 16,
                      )
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Great!'),
            ),
          ],
        );
      },
    );
  }
  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _detector?.stopListening();
    _accelerometerSubscription.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine the device orientation
    var orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      body: SafeArea(
        child: orientation == Orientation.portrait
            ? portraitLayout(context)
            : landscapeLayout(context),
      ),
    );
  }

  Widget portraitLayout(BuildContext context) {
    return Consumer<TerpiezLocationProvider>(
      builder: (context, locationProvider, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  'Terpiez Finder',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 36),
                ),
              ),
            ),
            Expanded(
              child: GoogleMap(
                mapType: MapType.normal,
                myLocationEnabled: true,
                initialCameraPosition: _initialPosition,
                markers: locationProvider.markers,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: infoText(),
            ),
          ],
        );
      },
    );
  }

  Widget landscapeLayout(BuildContext context) {
    return Consumer<TerpiezLocationProvider>(
      builder: (context, locationProvider, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Terpiez Finder',
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: GoogleMap(
                      mapType: MapType.normal,
                      myLocationEnabled: true,
                      initialCameraPosition: _initialPosition,
                      markers: locationProvider.markers,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: infoText(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget infoText() {
    return Consumer<ButtonStateProvider>(
        builder: (context, buttonState, child) {
          return Consumer<TerpiezLocationProvider>(
              builder: (context, locationProvider, child) {
                String distanceText = "${locationProvider.closestTerpiezDistance
                    .toStringAsFixed(0)}m";
                bool isTerpiezInRange = locationProvider.isTerpiezInRange;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Closest Terpiez:',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      distanceText,
                      style: TextStyle(
                        fontSize: 20,
                        color: isTerpiezInRange? Colors.green :Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    ElevatedButton(
                      onPressed: buttonState.isEnabled && isTerpiezInRange ? () {
                        Provider.of<TerpiezCounterProvider>(
                            context, listen: false)
                            .catchTerpiez();
                        Provider.of<TerpiezLocationProvider>(
                            context, listen: false).catchTerpiez();
                        context.read<TerpiezLocationProvider>().catchTerpiez();
                        buttonState.disableButton();
                      } : null,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50
                      ),
                      child: Text('Catch it!',
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              });
        }
    );
  }
}
class ButtonStateProvider with ChangeNotifier {
  bool _isEnabled = true;

  bool get isEnabled => _isEnabled;

  void disableButton() {
    _isEnabled = false;
    notifyListeners();

    Future.delayed(Duration(seconds: 4), () {
      _isEnabled = true;
      notifyListeners();
    });
  }
}