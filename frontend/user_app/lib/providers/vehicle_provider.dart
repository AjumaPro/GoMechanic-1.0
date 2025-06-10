import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class VehicleProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final _baseUrl = 'http://localhost:3000/api'; // Update with your API URL
  List<Map<String, dynamic>> _vehicles = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get vehicles => _vehicles;

  Future<bool> loadVehicles() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'token');
      if (token == null) return false;

      final response = await http.get(
        Uri.parse('$_baseUrl/vehicles'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _vehicles = List<Map<String, dynamic>>.from(data['vehicles']);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getVehicle(String vehicleId) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/vehicles/$vehicleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['vehicle'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> addVehicle({
    required String make,
    required String model,
    required int year,
    required String licensePlate,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'token');
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$_baseUrl/vehicles'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'make': make,
          'model': model,
          'year': year,
          'license_plate': licensePlate,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        _vehicles.add(data['vehicle']);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateVehicle(
    String vehicleId, {
    required String make,
    required String model,
    required int year,
    required String licensePlate,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'token');
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('$_baseUrl/vehicles/$vehicleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'make': make,
          'model': model,
          'year': year,
          'license_plate': licensePlate,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final index = _vehicles.indexWhere((v) => v['id'] == vehicleId);
        if (index != -1) {
          _vehicles[index] = data['vehicle'];
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteVehicle(String vehicleId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'token');
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$_baseUrl/vehicles/$vehicleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _vehicles.removeWhere((v) => v['id'] == vehicleId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
