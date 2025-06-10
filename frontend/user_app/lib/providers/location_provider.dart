import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gomechanic_user/config/api.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;
  bool _isTracking = false;
  bool get isTracking => _isTracking;

  Future<bool> requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<void> getCurrentLocation() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) return;

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> startTracking(String bookingId) async {
    if (!await requestLocationPermission()) return;

    _isTracking = true;
    notifyListeners();

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) async {
      _currentPosition = position;
      notifyListeners();

      // Update location on server
      try {
        await http.post(
          Uri.parse('${Api.baseUrl}/bookings/$bookingId/location'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${Api.token}',
          },
          body: json.encode({
            'latitude': position.latitude,
            'longitude': position.longitude,
            'accuracy': position.accuracy,
            'speed': position.speed,
            'heading': position.heading,
          }),
        );
      } catch (e) {
        debugPrint('Error updating location: $e');
      }
    });
  }

  void stopTracking() {
    _isTracking = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getServiceProviderLocation(
      String bookingId) async {
    try {
      final response = await http.get(
        Uri.parse('${Api.baseUrl}/bookings/$bookingId/provider-location'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Api.token}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting provider location: $e');
      return null;
    }
  }
}
