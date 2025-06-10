import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gomechanic_mechanic/providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSection(
            'Account',
            [
              _buildSettingTile(
                icon: Icons.person_outline,
                title: 'Profile',
                onTap: () {
                  // TODO: Navigate to profile edit screen
                },
              ),
              _buildSettingTile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                onTap: () {
                  // TODO: Navigate to change password screen
                },
              ),
            ],
          ),
          _buildSection(
            'Preferences',
            [
              _buildSettingTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () {
                  // TODO: Navigate to notification settings
                },
              ),
              _buildSettingTile(
                icon: Icons.language_outlined,
                title: 'Language',
                subtitle: 'English',
                onTap: () {
                  // TODO: Show language selection
                },
              ),
              _buildSettingTile(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                trailing: Switch(
                  value: false,
                  onChanged: (value) {
                    // TODO: Implement dark mode toggle
                  },
                ),
                onTap: () {},
              ),
            ],
          ),
          _buildSection(
            'App Settings',
            [
              _buildSettingTile(
                icon: Icons.location_on_outlined,
                title: 'Location Services',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement location services toggle
                  },
                ),
                onTap: () {},
              ),
              _buildSettingTile(
                icon: Icons.phone_android_outlined,
                title: 'App Updates',
                subtitle: 'Auto-update enabled',
                onTap: () {
                  // TODO: Show update settings
                },
              ),
            ],
          ),
          _buildSection(
            'Support',
            [
              _buildSettingTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {
                  // TODO: Navigate to help screen
                },
              ),
              _buildSettingTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {
                  // TODO: Show privacy policy
                },
              ),
              _buildSettingTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                onTap: () {
                  // TODO: Show terms of service
                },
              ),
            ],
          ),
          _buildSection(
            'Account Actions',
            [
              _buildSettingTile(
                icon: Icons.logout,
                title: 'Logout',
                textColor: Colors.red,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<AuthProvider>().logout();
                            Navigator.pop(context);
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
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

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
