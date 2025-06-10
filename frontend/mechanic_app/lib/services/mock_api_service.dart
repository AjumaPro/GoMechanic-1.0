import 'dart:async';
import 'dart:convert';
import 'package:gomechanic_mechanic/data/mock_data.dart';
import 'package:gomechanic_mechanic/services/storage_service.dart';
import 'package:gomechanic_mechanic/services/api_service.dart';

class MockApiService implements ApiService {
  final StorageService _storageService;
  final String _baseUrl;

  MockApiService(this._storageService, this._baseUrl);

  @override
  Future<Map<String, dynamic>> get(String endpoint) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    switch (endpoint) {
      case '/v1/jobs/active':
        return {
          'data': [
            {
              'id': '1',
              'service_type': 'General Service',
              'customer_name': 'John Smith',
              'address': '123 Main St, City',
              'status': 'pending',
              'amount': 1500.00,
              'vehicle': {
                'make': 'Honda',
                'model': 'City',
                'year': '2020',
              },
              'scheduled_at': '2024-03-20T10:00:00Z',
            },
            {
              'id': '2',
              'service_type': 'AC Service',
              'customer_name': 'Jane Doe',
              'address': '456 Park Ave, City',
              'status': 'accepted',
              'amount': 2000.00,
              'vehicle': {
                'make': 'Toyota',
                'model': 'Innova',
                'year': '2021',
              },
              'scheduled_at': '2024-03-21T14:00:00Z',
            },
          ],
        };

      case '/v1/jobs/completed':
        return {
          'data': [
            {
              'id': '3',
              'service_type': 'Brake Service',
              'customer_name': 'Mike Johnson',
              'address': '789 Oak St, City',
              'status': 'completed',
              'amount': 3000.00,
              'vehicle': {
                'make': 'Hyundai',
                'model': 'Creta',
                'year': '2019',
              },
              'completed_at': '2024-03-19T16:00:00Z',
              'notes': 'Brake pads replaced, brake fluid changed',
            },
            {
              'id': '4',
              'service_type': 'Engine Repair',
              'customer_name': 'Sarah Wilson',
              'address': '321 Pine Rd, City',
              'status': 'completed',
              'amount': 5000.00,
              'vehicle': {
                'make': 'Maruti',
                'model': 'Swift',
                'year': '2018',
              },
              'completed_at': '2024-03-18T11:00:00Z',
              'notes': 'Engine oil leak fixed, gasket replaced',
            },
          ],
        };

      default:
        throw Exception('Endpoint not found');
    }
  }

  @override
  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    switch (endpoint) {
      case '/v1/jobs/accept':
      case '/v1/jobs/start':
      case '/v1/jobs/complete':
      case '/v1/jobs/notes':
        return {
          'success': true,
          'message': 'Operation successful',
        };

      default:
        throw Exception('Endpoint not found');
    }
  }

  @override
  Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> data) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> delete(String endpoint) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'token': 'mock_token',
      'user': {
        'id': '1',
        'name': 'John Doe',
        'email': email,
      }
    };
  }

  @override
  Future<Map<String, dynamic>> getMechanicProfile() async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'id': '1',
      'name': 'John Doe',
      'email': 'john@example.com',
      'phone': '+1234567890',
      'rating': 4.5,
      'total_ratings': 100,
      'jobs_completed': 50,
    };
  }

  @override
  Future<Map<String, dynamic>> updateMechanicProfile(
      Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    return {'success': true, 'message': 'Profile updated successfully'};
  }

  @override
  Future<Map<String, dynamic>> updateBankingDetails(
      Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    return {'success': true, 'message': 'Banking details updated successfully'};
  }

  @override
  Future<Map<String, dynamic>> uploadDocument(
      String type, String filePath) async {
    await Future.delayed(const Duration(seconds: 1));
    return {'success': true, 'message': 'Document uploaded successfully'};
  }
}
