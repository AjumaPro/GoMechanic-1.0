import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:gomechanic_mechanic/config/api.dart';
import 'package:gomechanic_mechanic/models/job.dart';
import 'package:gomechanic_mechanic/services/api_service.dart';

class JobProvider extends ChangeNotifier {
  final ApiService _apiService;
  List<Job> _activeJobs = [];
  List<Job> _completedJobs = [];
  bool _isLoading = false;
  String? _error;

  JobProvider(this._apiService);

  List<Job> get activeJobs => _activeJobs;
  List<Job> get completedJobs => _completedJobs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadActiveJobs() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.get('/v1/jobs/active');
      _activeJobs = (response['jobs'] as List)
          .map((job) => Job.fromJson(job as Map<String, dynamic>))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadCompletedJobs() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.get('/v1/jobs/completed');
      _completedJobs = (response['jobs'] as List)
          .map((job) => Job.fromJson(job as Map<String, dynamic>))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> acceptJob(String jobId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _apiService.post('/v1/jobs/accept', {'job_id': jobId});
      await loadActiveJobs();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> startJob(String jobId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _apiService.post('/v1/jobs/start', {'job_id': jobId});
      await loadActiveJobs();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> completeJob(String jobId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _apiService.post('/v1/jobs/complete', {'job_id': jobId});
      await loadActiveJobs();
      await loadCompletedJobs();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> updateJobStatus(String jobId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('${Api.baseUrl}/jobs/$jobId/'),
        headers: Api.headers,
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        await loadActiveJobs();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> addJobNotes(String jobId, String notes) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _apiService.post('/v1/jobs/notes', {
        'job_id': jobId,
        'notes': notes,
      });
      await loadActiveJobs();
      await loadCompletedJobs();

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
