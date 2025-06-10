import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gomechanic_user/providers/auth_provider.dart';
import 'package:gomechanic_user/screens/profile/edit_profile_screen.dart';
import 'package:gomechanic_user/screens/profile/change_password_screen.dart';
import 'package:gomechanic_user/screens/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = await context.read<AuthProvider>().getCurrentUser();
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: _user?['profile_image'] != null
                                ? NetworkImage(_user!['profile_image'])
                                : null,
                            child: _user?['profile_image'] == null
                                ? const Icon(Icons.person, size: 50)
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _user?['name'] ?? 'User',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _user?['email'] ?? '',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildProfileSection(
                      title: 'Personal Information',
                      children: [
                        _buildProfileTile(
                          icon: Icons.person,
                          title: 'Edit Profile',
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            );
                            _loadUserProfile();
                          },
                        ),
                        _buildProfileTile(
                          icon: Icons.phone,
                          title: 'Phone',
                          subtitle: _user?['phone'] ?? 'Not set',
                        ),
                        _buildProfileTile(
                          icon: Icons.location_on,
                          title: 'Address',
                          subtitle: _user?['address'] ?? 'Not set',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildProfileSection(
                      title: 'Security',
                      children: [
                        _buildProfileTile(
                          icon: Icons.lock,
                          title: 'Change Password',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ChangePasswordScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildProfileSection(
                      title: 'Payments',
                      children: [
                        _buildProfileTile(
                          icon: Icons.payment,
                          title: 'Payment History',
                          onTap: () {
                            Navigator.of(context).pushNamed('/payment-history');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildProfileSection(
                      title: 'App Settings',
                      children: [
                        _buildProfileTile(
                          icon: Icons.notifications,
                          title: 'Notifications',
                          onTap: () {
                            // TODO: Implement notifications settings
                          },
                        ),
                        _buildProfileTile(
                          icon: Icons.language,
                          title: 'Language',
                          subtitle: 'English',
                          onTap: () {
                            // TODO: Implement language settings
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }
}
