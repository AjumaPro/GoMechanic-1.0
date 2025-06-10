import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSearchBar(),
          const SizedBox(height: 24),
          _buildSection(
            'Frequently Asked Questions',
            [
              _buildFAQItem(
                'How do I accept a job?',
                'To accept a job, go to the Active Jobs tab and tap on a job card. Then click the "Accept Job" button on the job details screen.',
              ),
              _buildFAQItem(
                'How do I update job status?',
                'You can update the job status by going to the job details screen and using the action buttons (Start Job, Complete Job) based on the current status.',
              ),
              _buildFAQItem(
                'How do I add notes to a job?',
                'On the job details screen, scroll down to the Notes section and use the text field to add your notes. Click "Add Notes" to save.',
              ),
              _buildFAQItem(
                'How do I view my earnings?',
                'Go to the Earnings tab to view your total earnings, daily/weekly/monthly breakdown, and detailed earnings history.',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Contact Support',
            [
              _buildContactItem(
                Icons.phone_outlined,
                'Call Support',
                '+233 20 123 4567',
                () {
                  // TODO: Implement phone call
                },
              ),
              _buildContactItem(
                Icons.email_outlined,
                'Email Support',
                'support@gomechanic.com',
                () {
                  // TODO: Implement email
                },
              ),
              _buildContactItem(
                Icons.chat_outlined,
                'Live Chat',
                'Available 24/7',
                () {
                  // TODO: Implement live chat
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Quick Links',
            [
              _buildLinkItem(
                'Privacy Policy',
                () {
                  // TODO: Show privacy policy
                },
              ),
              _buildLinkItem(
                'Terms of Service',
                () {
                  // TODO: Show terms of service
                },
              ),
              _buildLinkItem(
                'User Guide',
                () {
                  // TODO: Show user guide
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search for help...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLinkItem(String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
