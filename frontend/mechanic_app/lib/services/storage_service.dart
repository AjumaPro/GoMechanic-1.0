import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final FlutterSecureStorage _storage;

  StorageService() : _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'token');
  }

  Future<void> saveUserData(Map<String, dynamic> data) async {
    await _storage.write(key: 'user_data', value: data.toString());
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final data = await _storage.read(key: 'user_data');
    if (data == null) return null;
    // TODO: Implement proper JSON parsing
    return {};
  }

  Future<void> deleteUserData() async {
    await _storage.delete(key: 'user_data');
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
