import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gomechanic_mechanic/config/theme.dart';
import 'package:gomechanic_mechanic/providers/job_provider.dart';
import 'package:gomechanic_mechanic/models/job.dart';

class JobDetailsScreen extends StatefulWidget {
  final Job job;

  const JobDetailsScreen({
    Key? key,
    required this.job,
  }) : super(key: key);

  @override
  _JobDetailsScreenState createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final _notesController = TextEditingController();
  bool _isLoading = false;
  bool _isExpanded = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleJobAction(String action) async {
    setState(() => _isLoading = true);

    try {
      final jobProvider = context.read<JobProvider>();
      switch (action) {
        case 'accept':
          await jobProvider.acceptJob(widget.job.id);
          break;
        case 'start':
          await jobProvider.startJob(widget.job.id);
          break;
        case 'complete':
          await jobProvider.completeJob(widget.job.id);
          break;
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addNotes() async {
    if (_notesController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await context
          .read<JobProvider>()
          .addJobNotes(widget.job.id, _notesController.text);
      _notesController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notes added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                  const SizedBox(height: 16),
                  _buildNotesSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.job.serviceType,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Customer: ${widget.job.customerName}'),
            Text('Location: ${widget.job.location}'),
            Text('Status: ${widget.job.status}'),
            if (widget.job.completedAt != null)
              Text(
                  'Completed: ${widget.job.completedAt!.toLocal().toString()}'),
            if (widget.job.notes != null) ...[
              const SizedBox(height: 8),
              Text('Notes: ${widget.job.notes}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (widget.job.status == 'pending')
          ElevatedButton(
            onPressed: () => _handleJobAction('accept'),
            child: const Text('Accept Job'),
          ),
        if (widget.job.status == 'accepted')
          ElevatedButton(
            onPressed: () => _handleJobAction('start'),
            child: const Text('Start Job'),
          ),
        if (widget.job.status == 'in_progress')
          ElevatedButton(
            onPressed: () => _handleJobAction('complete'),
            child: const Text('Complete Job'),
          ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Notes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter notes about this job...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _addNotes,
              child: const Text('Add Notes'),
            ),
          ],
        ),
      ),
    );
  }
}
