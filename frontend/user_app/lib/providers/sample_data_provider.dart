import 'package:flutter/foundation.dart';

class SampleDataProvider with ChangeNotifier {
  // Sample services
  final List<Map<String, dynamic>> services = [
    {
      'id': '1',
      'name': 'Basic Service',
      'description': 'Oil change, filter replacement, and basic inspection',
      'price': 999.0,
      'duration': 60, // minutes
      'image': 'assets/images/services/basic_service.png',
    },
    {
      'id': '2',
      'name': 'Premium Service',
      'description': 'Complete vehicle checkup and maintenance',
      'price': 2499.0,
      'duration': 120,
      'image': 'assets/images/services/premium_service.png',
    },
    {
      'id': '3',
      'name': 'AC Service',
      'description': 'AC system cleaning and gas refill',
      'price': 1499.0,
      'duration': 90,
      'image': 'assets/images/services/ac_service.png',
    },
  ];

  // Sample vehicles
  final List<Map<String, dynamic>> vehicles = [
    {
      'id': '1',
      'brand': 'Honda',
      'model': 'City',
      'year': 2020,
      'license_plate': 'MH01AB1234',
      'color': 'White',
      'image': 'assets/images/vehicles/honda_city.png',
    },
    {
      'id': '2',
      'brand': 'Hyundai',
      'model': 'Creta',
      'year': 2021,
      'license_plate': 'MH02CD5678',
      'color': 'Black',
      'image': 'assets/images/vehicles/hyundai_creta.png',
    },
  ];

  // Sample bookings
  final List<Map<String, dynamic>> bookings = [
    {
      'id': '1',
      'service_id': '1',
      'vehicle_id': '1',
      'status': 'upcoming',
      'scheduled_at':
          DateTime.now().add(const Duration(days: 2)).toIso8601String(),
      'created_at':
          DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'notes': 'Please check the brakes',
    },
    {
      'id': '2',
      'service_id': '2',
      'vehicle_id': '2',
      'status': 'completed',
      'scheduled_at':
          DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      'created_at':
          DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      'notes': 'Regular maintenance',
    },
  ];

  // Sample payments
  final List<Map<String, dynamic>> payments = [
    {
      'id': '1',
      'booking_id': '1',
      'amount': 999.0,
      'currency': 'INR',
      'status': 'pending',
      'payment_method': 'card',
      'created_at':
          DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
    {
      'id': '2',
      'booking_id': '2',
      'amount': 2499.0,
      'currency': 'INR',
      'status': 'completed',
      'payment_method': 'upi',
      'created_at':
          DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
    },
  ];

  // Sample user profile
  final Map<String, dynamic> userProfile = {
    'id': '1',
    'name': 'John Doe',
    'email': 'john@example.com',
    'phone': '+91 9876543210',
    'address': '123 Main St, Mumbai, Maharashtra',
    'profile_image': 'assets/images/profile/default_profile.png',
  };

  // Sample mechanics
  final List<Map<String, dynamic>> mechanics = [
    {
      'id': '1',
      'name': 'Rajesh Kumar',
      'rating': 4.5,
      'experience': 5,
      'specialization': ['Engine', 'Transmission'],
      'image': 'assets/images/mechanics/mechanic1.png',
      'is_available': true,
    },
    {
      'id': '2',
      'name': 'Amit Singh',
      'rating': 4.8,
      'experience': 8,
      'specialization': ['AC', 'Electrical'],
      'image': 'assets/images/mechanics/mechanic2.png',
      'is_available': true,
    },
  ];

  // Sample reviews
  final List<Map<String, dynamic>> reviews = [
    {
      'id': '1',
      'booking_id': '2',
      'mechanic_id': '1',
      'rating': 5,
      'comment': 'Excellent service! Very professional and thorough.',
      'created_at':
          DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
    },
    {
      'id': '2',
      'booking_id': '1',
      'mechanic_id': '2',
      'rating': 4,
      'comment': 'Good service, but a bit slow.',
      'created_at':
          DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
    },
  ];
}
