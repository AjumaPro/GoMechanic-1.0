import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class EarningsProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  double _totalEarnings = 0.0;
  int _jobsCompleted = 0;
  double _averageRating = 0.0;
  List<FlSpot> _earningsData = [];
  List<Earning> _recentEarnings = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  double get totalEarnings => _totalEarnings;
  int get jobsCompleted => _jobsCompleted;
  double get averageRating => _averageRating;
  List<FlSpot> get earningsData => _earningsData;
  List<Earning> get recentEarnings => _recentEarnings;

  Future<void> fetchEarnings(String period) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1)); // Simulate API delay

      // Mock data
      _totalEarnings = 12500.0;
      _jobsCompleted = 45;
      _averageRating = 4.8;
      _earningsData = [
        const FlSpot(0, 3),
        const FlSpot(1, 1),
        const FlSpot(2, 4),
        const FlSpot(3, 2),
        const FlSpot(4, 5),
        const FlSpot(5, 3),
        const FlSpot(6, 4),
      ];
      _recentEarnings = List.generate(
        5,
        (index) => Earning(
          jobId: 1000 + index,
          serviceType: 'General Service',
          timeAgo: '${index + 1} day${index == 0 ? '' : 's'} ago',
          amount: (index + 1) * 500.0,
        ),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
}

class Earning {
  final int jobId;
  final String serviceType;
  final String timeAgo;
  final double amount;

  Earning({
    required this.jobId,
    required this.serviceType,
    required this.timeAgo,
    required this.amount,
  });
}
