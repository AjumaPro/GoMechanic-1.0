import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gomechanic_mechanic/config/api.dart';

abstract class ApiService {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> getMechanicProfile();
  Future<Map<String, dynamic>> get(String endpoint);
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data);
  Future<Map<String, dynamic>> delete(String endpoint);
  Future<Map<String, dynamic>> updateMechanicProfile(Map<String, dynamic> data);
  Future<Map<String, dynamic>> updateBankingDetails(Map<String, dynamic> data);
  Future<Map<String, dynamic>> uploadDocument(String type, String filePath);
}

class ApiServiceImpl implements ApiService {
  final http.Client _client;

  ApiServiceImpl(this._client);

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _client.post(
      Uri.parse('${Api.baseUrl}/v1/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  @override
  Future<Map<String, dynamic>> getMechanicProfile() async {
    final response = await _client.get(
      Uri.parse('${Api.baseUrl}/v1/mechanics/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Api.token}',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get mechanic profile: ${response.body}');
    }
  }

  @override
  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await _client.get(
      Uri.parse('${Api.baseUrl}$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Api.token}',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get data: ${response.body}');
    }
  }

  @override
  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('${Api.baseUrl}$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Api.token}',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to post data: ${response.body}');
    }
  }

  @override
  Future<Map<String, dynamic>> delete(String endpoint) async {
    final response = await _client.delete(
      Uri.parse('${Api.baseUrl}$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Api.token}',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return response.body.isNotEmpty ? jsonDecode(response.body) : {};
    } else {
      throw Exception('Failed to delete data: ${response.body}');
    }
  }

  @override
  Future<Map<String, dynamic>> updateMechanicProfile(
      Map<String, dynamic> data) async {
    final token = Api.token;
    if (token == null) throw Exception('Not authenticated');

    final response = await _client.patch(
      Uri.parse('${Api.baseUrl}/v1/mechanics/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  @override
  Future<Map<String, dynamic>> updateBankingDetails(
      Map<String, dynamic> data) async {
    final token = Api.token;
    if (token == null) throw Exception('Not authenticated');

    final response = await _client.patch(
      Uri.parse('${Api.baseUrl}/v1/mechanics/banking'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update banking details: ${response.body}');
    }
  }

  @override
  Future<Map<String, dynamic>> uploadDocument(
      String type, String filePath) async {
    final token = Api.token;
    if (token == null) throw Exception('Not authenticated');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${Api.baseUrl}/v1/mechanics/documents'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    request.fields['type'] = type;
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to upload document: ${response.body}');
    }
  }
}
