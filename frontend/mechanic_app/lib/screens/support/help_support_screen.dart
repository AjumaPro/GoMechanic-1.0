import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        children: [
          _buildSection(
            'Frequently Asked Questions',
            [
              _buildFAQItem(
                'How do I accept a job?',
                'When a new job request comes in, you\'ll receive a notification. '
                    'Open the app, go to the Active Jobs tab, and tap on the job to view details. '
                    'You can then accept or decline the job.',
              ),
              _buildFAQItem(
                'How do I get paid?',
                'Payments are processed automatically after job completion. '
                    'You can view your earnings in the Earnings tab and withdraw them to your bank account.',
              ),
              _buildFAQItem(
                'What if I need to cancel a job?',
                'You can cancel a job from the Active Jobs tab. '
                    'Please note that frequent cancellations may affect your rating.',
              ),
              _buildFAQItem(
                'How do I update my profile?',
                'Go to the Profile tab and tap on the edit icon. '
                    'You can update your personal information, skills, and documents.',
              ),
            ],
          ),
          _buildSection(
            'Contact Support',
            [
              _buildContactTile(
                icon: Icons.phone,
                title: 'Call Support',
                subtitle: 'Available 24/7',
                onTap: () => _launchUrl('tel:+1234567890'),
              ),
              _buildContactTile(
                icon: Icons.email,
                title: 'Email Support',
                subtitle: 'support@gomechanic.com',
                onTap: () => _launchUrl('mailto:support@gomechanic.com'),
              ),
              _buildContactTile(
                icon: Icons.chat,
                title: 'Live Chat',
                subtitle: 'Chat with our support team',
                onTap: () {
                  // TODO: Implement live chat
                },
              ),
            ],
          ),
          _buildSection(
            'Resources',
            [
              _buildResourceTile(
                icon: Icons.book,
                title: 'User Guide',
                onTap: () {
                  // TODO: Show user guide
                },
              ),
              _buildResourceTile(
                icon: Icons.video_library,
                title: 'Video Tutorials',
                onTap: () {
                  // TODO: Show video tutorials
                },
              ),
              _buildResourceTile(
                icon: Icons.feedback,
                title: 'Send Feedback',
                onTap: () {
                  // TODO: Show feedback form
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildResourceTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
