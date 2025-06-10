import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gomechanic_mechanic/config/api.dart';
import 'package:gomechanic_mechanic/models/mechanic.dart';
import 'package:gomechanic_mechanic/services/api_service.dart';
import 'package:gomechanic_mechanic/services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;
  Mechanic? _mechanic;
  bool _isLoading = false;
  String? _error;
  bool _isGuest = false;

  AuthProvider(this._apiService, this._storageService);

  Mechanic? get mechanic => _mechanic;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _mechanic != null;
  bool get isGuest => _isGuest;
  bool get isLoggedIn => _mechanic != null || _isGuest;

  Future<bool> checkAuth() async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        _mechanic = null;
        Api.clearToken();
        return false;
      }

      Api.setToken(token);
      await _fetchMechanicProfile();
      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      _isGuest = false;
      notifyListeners();

      final response = await _apiService.login(email, password);
      await _storageService.saveToken(response['token']);
      await _fetchMechanicProfile();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loginAsGuest() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Create a guest mechanic profile
      _mechanic = Mechanic(
        id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Guest Mechanic',
        email: 'guest@example.com',
        phone: 'N/A',
        rating: 0.0,
        totalRatings: 0,
        jobsCompleted: 0,
        activeJobs: 0,
        totalEarnings: 0.0,
        skills: [],
        idCardVerified: false,
        licenseVerified: false,
        insuranceVerified: false,
      );
      _isGuest = true;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _storageService.deleteToken();
      _mechanic = null;
      _isGuest = false;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _fetchMechanicProfile() async {
    try {
      final response = await _apiService.getMechanicProfile();
      _mechanic = Mechanic.fromJson(response);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.updateMechanicProfile(data);
      _mechanic = Mechanic.fromJson(response);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateBankingDetails(Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.updateBankingDetails(data);
      _mechanic = Mechanic.fromJson(response);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> uploadDocument(String type, String filePath) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.uploadDocument(type, filePath);
      _mechanic = Mechanic.fromJson(response);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
