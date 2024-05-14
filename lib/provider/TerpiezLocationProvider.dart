import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../redis/RedisService.dart';
import '../service/ImageService.dart';
import '../service/TerpiezService.dart';

class TerpiezLocationProvider with ChangeNotifier {
  final RedisService _redisService = RedisService();
  List<Map<String, dynamic>> _terpiezLocations = [];
  double _closestTerpiezDistance = double.infinity;
  bool _isTerpiezInRange = false;
  Set<Marker> _markers = {};
  double? _userLatitude;
  double? _userLongitude;
  Map<String, dynamic>? _closestTerpiez;
  bool _isCatching = false;
  Map<String, dynamic>? _lastCaughtTerpiez;

  final RedisService redisService;
  final ImageService imageService;
  late final TerpiezService terpiezService;
  StreamSubscription<bool>? _connectionSub;

  TerpiezLocationProvider({
    required this.redisService,
    required this.imageService,
  }) {
    terpiezService = TerpiezService(redisService, imageService);
    _connectionSub = redisService.onConnectionChange.listen(_handleConnectionChange);
    _fetchAndStoreLocations();
    _handleConnectionChange(redisService.isConnectionSuccessful);
  }

  double get closestTerpiezDistance => _closestTerpiezDistance;
  bool get isTerpiezInRange => _isTerpiezInRange;
  List<Map<String, dynamic>> get terpiezLocations => _terpiezLocations;
  Set<Marker> get markers => _markers;
  bool get isCatching => _isCatching;
  Map<String, dynamic>? get lastCaughtTerpiez => _lastCaughtTerpiez;

  set isCatching(bool catching) {
    _isCatching = catching;
    notifyListeners();
  }

  void resetLocations() {
    final prefs = SharedPreferences.getInstance();
    prefs.then((preferences) {
      preferences.remove('caughtTerpiezIdentifiers');
      preferences.setDouble('closestDistance', double.infinity);
    });

    _fetchAndStoreLocations();
    notifyListeners();
  }

  void _handleConnectionChange(bool isConnected) {
    if (!isConnected) {
      _terpiezLocations.clear();
      _markers.clear();
      _closestTerpiezDistance = double.infinity;
      _closestTerpiez = null;
      _isTerpiezInRange = false;
      notifyListeners();
    } else {
      _fetchAndStoreLocations();
    }
  }

  Future<void> _fetchAndStoreLocations() async {
    final prefs = await SharedPreferences.getInstance();
    Set<String> caughtTerpiezIdentifiers = (prefs.getStringList('caughtTerpiezIdentifiers') ?? []).toSet();
    try {
      List<dynamic>? fetchedLocations = await _redisService
          .fetchTerpiezLocations();
      if (fetchedLocations != null) {
        _terpiezLocations =
            fetchedLocations.map<Map<String, dynamic>>((location) {
              return {
                'id': location['id'],
                'latitude': location['lat'],
                'longitude': location['lon'],
              };
            }).where((location) => !caughtTerpiezIdentifiers.contains('${location['id']}:${location['latitude']}:${location['longitude']}')).toList();
      } else {
        print('No locations were fetched.');
      }
    } catch (e) {
      print('Failed to fetch locations: $e');
    }
    updateMarkers();
    if (_userLatitude != null && _userLongitude != null) {
      updateClosestTerpiezDistance(_userLatitude!, _userLongitude!);
    }
    notifyListeners();
  }

  void setUserLocation(double latitude, double longitude) {
    _userLatitude = latitude;
    _userLongitude = longitude;
    updateClosestTerpiezDistance(latitude, longitude);
    notifyListeners();
  }

  Future<void> updateClosestTerpiezDistance(double latitude, double longitude) async {
    double closestDistance = double.infinity;
    Map<String, dynamic>? closestTerpiezTemp;

    if (_terpiezLocations.isEmpty) {
      _closestTerpiezDistance = double.infinity;
      _closestTerpiez = null;
      _isTerpiezInRange = false;
      notifyListeners();
      return;
    }

    print('Updating closest Terpiez with user latitude: $latitude and longitude: $longitude');
    print('Number of Terpiez locations: ${_terpiezLocations.length}');

    for (var location in _terpiezLocations) {
      double terpiezLat = location['latitude'];
      double terpiezLong = location['longitude'];
      final distance = Geolocator.distanceBetween(
        latitude, longitude, terpiezLat, terpiezLong,
      );

      if (distance < closestDistance) {
        closestDistance = distance;
        closestTerpiezTemp = location;
        print('New closest Terpiez found at distance $distance');
      }
    }

    if (closestDistance != double.infinity && closestTerpiezTemp != null) {
      _closestTerpiezDistance = closestDistance;
      _closestTerpiez = closestTerpiezTemp;
      _isTerpiezInRange = closestDistance <= 10;
      updateMarkers();
    } else {
      _isTerpiezInRange = false;
      _closestTerpiez = null;
      print('No closest Terpiez location found. No marker added.');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('closestDistance', closestDistance);
    await prefs.reload();
    print('Updated closestDistance to $closestDistance');
    notifyListeners();
  }

  Future<void> catchTerpiez() async {
    if (_closestTerpiez == null) {
      print('No closest Terpiez to catch.');
      return;
    }

    print('Attempting to catch Terpiez with ID: $_closestTerpiez');
    final terpiezId = _closestTerpiez!['id'];
    final latitude = _closestTerpiez!['latitude'] ;
    final longitude = _closestTerpiez!['longitude'] ;
    final uniqueTerpiezIdentifier = '$terpiezId:$latitude:$longitude';

    print('Latitude: $latitude');
    print('Longitude: $longitude');
    try {
      await terpiezService.catchAndStoreTerpiez(terpiezId, latitude, longitude);
      final prefs = await SharedPreferences.getInstance();
      Set<String> caughtTerpiezIdentifiers = (prefs.getStringList('caughtTerpiezIdentifiers') ?? []).toSet();
      caughtTerpiezIdentifiers.add(uniqueTerpiezIdentifier);
      await prefs.setStringList('caughtTerpiezIdentifiers', caughtTerpiezIdentifiers.toList());

      _terpiezLocations.removeWhere((terpiez) =>
      '$terpiezId:${terpiez['latitude']}:${terpiez['longitude']}' == uniqueTerpiezIdentifier);

      updateMarkers();

      if (_userLatitude != null && _userLongitude != null) {
        updateClosestTerpiezDistance(_userLatitude!, _userLongitude!);
      }

      notifyListeners();

      if (_closestTerpiez != null) {
        try {
          await terpiezService.catchAndStoreTerpiez(terpiezId, latitude, longitude);
          _lastCaughtTerpiez = await redisService.fetchTerpiezDetails(terpiezId);
          String imageData = await redisService.fetchImageData(_lastCaughtTerpiez!['image']);
          _lastCaughtTerpiez!['imageData'] = imageData;
          notifyListeners();  // Notify to update the UI
          showDialogAfterCatching();  // Call to show dialog
        } catch (e) {
          print("Error catching Terpiez: $e");
        }
      }
    } catch (e) {
      print("Error catching Terpiez: $e");
    }
  }

  void showDialogAfterCatching() {
    if (_lastCaughtTerpiez != null) {
      print("Show dialog for last caught Terpiez: $_lastCaughtTerpiez");
    }
  }

  void updateMarkers() {
    _markers.clear();

    if (_closestTerpiez != null) {
      final markerId = MarkerId(_closestTerpiez!['id'].toString());
      double latitude = _closestTerpiez!['latitude'];
      double longitude = _closestTerpiez!['longitude'];

      final marker = Marker(
        markerId: markerId,
        position: LatLng(latitude, longitude),
        infoWindow: InfoWindow(title: _closestTerpiez!['id']),
        icon: BitmapDescriptor.defaultMarker,
      );

      _markers.add(marker);
      print('Added marker at $latitude, $longitude for the closest Terpiez');
    } else {
      print('No closest Terpiez location found.');
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _connectionSub?.cancel();
    super.dispose();
  }
}
