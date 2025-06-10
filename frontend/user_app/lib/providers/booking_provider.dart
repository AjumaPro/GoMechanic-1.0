import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:gomechanic_user/config/api.dart';

class BookingProvider with ChangeNotifier {
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get bookings => _bookings;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> get upcomingBookings {
    return _bookings.where((b) => b['status'] == 'upcoming').toList();
  }

  List<Map<String, dynamic>> get completedBookings {
    return _bookings.where((b) => b['status'] == 'completed').toList();
  }

  List<Map<String, dynamic>> get cancelledBookings {
    return _bookings.where((b) => b['status'] == 'cancelled').toList();
  }

  Future<bool> loadBookings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${Api.baseUrl}/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Api.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _bookings = List<Map<String, dynamic>>.from(data['bookings']);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error loading bookings: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBooking({
    required String serviceId,
    required String vehicleId,
    required DateTime dateTime,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${Api.baseUrl}/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Api.token}',
        },
        body: json.encode({
          'service_id': serviceId,
          'vehicle_id': vehicleId,
          'scheduled_at': dateTime.toIso8601String(),
          'notes': notes,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        _bookings.add(data['booking']);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error creating booking: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${Api.baseUrl}/bookings/$bookingId/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Api.token}',
        },
      );

      if (response.statusCode == 200) {
        final index = _bookings.indexWhere((b) => b['id'] == bookingId);
        if (index != -1) {
          _bookings[index]['status'] = 'cancelled';
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error cancelling booking: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> rescheduleBooking(
    String bookingId,
    DateTime newDateTime,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${Api.baseUrl}/bookings/$bookingId/reschedule'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Api.token}',
        },
        body: json.encode({
          'scheduled_at': newDateTime.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final index = _bookings.indexWhere((b) => b['id'] == bookingId);
        if (index != -1) {
          _bookings[index] = data['booking'];
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error rescheduling booking: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getBookingDetails(String bookingId) async {
    try {
      final response = await http.get(
        Uri.parse('${Api.baseUrl}/bookings/$bookingId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Api.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['booking'];
      }
      return null;
    } catch (e) {
      debugPrint('Error getting booking details: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getServiceDetails(String serviceId) async {
    try {
      final response = await http.get(
        Uri.parse('${Api.baseUrl}/services/$serviceId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Api.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['service'];
      }
      return null;
    } catch (e) {
      debugPrint('Error getting service details: $e');
      return null;
    }
  }
}
