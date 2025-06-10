import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gomechanic_mechanic/providers/auth_provider.dart';
import 'package:gomechanic_mechanic/models/mechanic.dart';
import 'package:gomechanic_mechanic/screens/profile/edit_profile_screen.dart';
import 'package:gomechanic_mechanic/screens/profile/banking_details_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mechanic = context.watch<AuthProvider>().mechanic;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context, mechanic),
            _buildStatsSection(mechanic),
            _buildSkillsSection(mechanic),
            _buildDocumentsSection(mechanic),
            _buildBankingSection(context, mechanic),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, Mechanic? mechanic) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: mechanic?.profileImage != null
                ? NetworkImage(mechanic!.profileImage!)
                : null,
            child: mechanic?.profileImage == null
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            mechanic?.name ?? 'Not Set',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mechanic?.email ?? 'Not Set',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                mechanic?.rating?.toStringAsFixed(1) ?? '0.0',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${mechanic?.totalRatings ?? 0} reviews)',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(Mechanic? mechanic) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Jobs Completed',
            mechanic?.jobsCompleted?.toString() ?? '0',
            Icons.check_circle_outline,
          ),
          _buildStatItem(
            'Active Jobs',
            mechanic?.activeJobs?.toString() ?? '0',
            Icons.work_outline,
          ),
          _buildStatItem(
            'Earnings',
            '\$${mechanic?.totalEarnings?.toStringAsFixed(2) ?? '0.00'}',
            Icons.attach_money,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsSection(Mechanic? mechanic) {
    return _buildSection(
      'Skills & Specializations',
      [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: (mechanic?.skills ?? []).map((skill) {
            return Chip(
              label: Text(skill),
              backgroundColor: Colors.blue.withOpacity(0.1),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDocumentsSection(Mechanic? mechanic) {
    return _buildSection(
      'Documents',
      [
        _buildDocumentItem(
          'ID Card',
          mechanic?.idCardVerified ?? false,
          Icons.badge_outlined,
        ),
        _buildDocumentItem(
          'Driver\'s License',
          mechanic?.licenseVerified ?? false,
          Icons.drive_file_rename_outline,
        ),
        _buildDocumentItem(
          'Insurance',
          mechanic?.insuranceVerified ?? false,
          Icons.security_outlined,
        ),
      ],
    );
  }

  Widget _buildDocumentItem(String title, bool isVerified, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: isVerified
          ? const Icon(Icons.check_circle, color: Colors.green)
          : const Icon(Icons.error_outline, color: Colors.orange),
    );
  }

  Widget _buildBankingSection(BuildContext context, Mechanic? mechanic) {
    return _buildSection(
      'Banking Information',
      [
        ListTile(
          leading: const Icon(Icons.account_balance),
          title: const Text('Bank Account'),
          subtitle: Text(
            mechanic?.bankAccountNumber ?? 'Not Set',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BankingDetailsScreen(),
              ),
            );
          },
        ),
      ],
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }
}
