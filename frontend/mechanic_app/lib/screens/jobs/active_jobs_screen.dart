import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gomechanic_mechanic/config/theme.dart';
import 'package:gomechanic_mechanic/providers/job_provider.dart';
import 'package:gomechanic_mechanic/screens/jobs/job_details_screen.dart';
import 'package:gomechanic_mechanic/models/job.dart';

class ActiveJobsScreen extends StatefulWidget {
  const ActiveJobsScreen({Key? key}) : super(key: key);

  @override
  _ActiveJobsScreenState createState() => _ActiveJobsScreenState();
}

class _ActiveJobsScreenState extends State<ActiveJobsScreen> {
  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    try {
      await context.read<JobProvider>().loadActiveJobs();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Jobs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadJobs,
          ),
        ],
      ),
      body: Consumer<JobProvider>(
        builder: (context, jobProvider, child) {
          if (jobProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (jobProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(jobProvider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadJobs,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (jobProvider.activeJobs.isEmpty) {
            return const Center(
              child: Text('No active jobs found'),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadJobs,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: jobProvider.activeJobs.length,
              itemBuilder: (context, index) {
                final job = jobProvider.activeJobs[index];
                return _buildJobCard(job);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildJobCard(Job job) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(job.serviceType),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${job.customerName}'),
            Text('Location: ${job.location}'),
            Text('Status: ${job.status}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {
            // TODO: Navigate to job details screen
          },
        ),
      ),
    );
  }
}
