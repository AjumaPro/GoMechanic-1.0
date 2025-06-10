import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gomechanic_user/config/api.dart';

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final _baseUrl = 'http://localhost:8007/api'; // Change to your API URL
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _token;
  bool _isGuest = false;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  bool get isGuest => _isGuest;
  bool get isLoggedIn => _token != null || _isGuest;

  Future<bool> checkAuth() async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        _isAuthenticated = false;
        _user = null;
        Api.clearToken();
        return false;
      }

      Api.setToken(token);
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/me/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        _isAuthenticated = true;
        _user = json.decode(response.body);
        notifyListeners();
        return true;
      } else {
        await logout();
        return false;
      }
    } catch (e) {
      await logout();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _storage.write(key: 'token', value: data['token']);
        Api.setToken(data['token']);
        _isAuthenticated = true;
        _user = data['user'];
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

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'role': 'customer',
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        await _storage.write(key: 'token', value: data['token']);
        Api.setToken(data['token']);
        _isAuthenticated = true;
        _user = data['user'];
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

  Future<void> logout() async {
    await _storage.delete(key: 'token');
    Api.clearToken();
    _isAuthenticated = false;
    _user = null;
    _token = null;
    _isGuest = false;
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) return false;

      final response = await http.patch(
        Uri.parse('$_baseUrl/auth/profile/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        _user = json.decode(response.body);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/change-password/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    if (_user != null) return _user;

    final token = await _storage.read(key: 'token');
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/me/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _user = data['user'];
        notifyListeners();
        return _user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateProfileImage(String imagePath) async {
    final token = await _storage.read(key: 'token');
    if (token == null) return false;

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/users/profile/image'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      request.files.add(
        await http.MultipartFile.fromPath('image', imagePath),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseData);
        _user = data['user'];
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> loginAsGuest() async {
    _user = {
      'id': 'guest_${DateTime.now().millisecondsSinceEpoch}',
      'name': 'Guest User',
      'email': 'guest@example.com',
      'phone': 'N/A',
    };
    _isGuest = true;
    notifyListeners();
  }
}
