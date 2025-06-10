import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gomechanic_user/config/api.dart';

class PaymentProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<Map<String, dynamic>?> initializePayment({
    required String bookingId,
    required double amount,
    required String currency,
    required String paymentMethod,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${Api.baseUrl}/payments/initialize'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Api.token}',
        },
        body: json.encode({
          'booking_id': bookingId,
          'amount': amount,
          'currency': currency,
          'payment_method': paymentMethod,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error initializing payment: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyPayment(String reference) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${Api.baseUrl}/payments/verify/$reference'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Api.token}',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error verifying payment: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    try {
      final response = await http.get(
        Uri.parse('${Api.baseUrl}/payments/history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Api.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['payments']);
      }
      return [];
    } catch (e) {
      debugPrint('Error getting payment history: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getPaymentDetails(String paymentId) async {
    try {
      final response = await http.get(
        Uri.parse('${Api.baseUrl}/payments/$paymentId'),
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
      debugPrint('Error getting payment details: $e');
      return null;
    }
  }
}
