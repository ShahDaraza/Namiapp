import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late AuthService _authService;
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final userData = await _authService.getUserData(user.uid);
        setState(() {
          _user = userData;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading user: $e');
    }
  }

  Future<void> _logout() async {
    try {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/auth/role-selection');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFF667EEA),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text('Error loading profile'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),

                      // Profile Picture
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _user!.profileImage.isNotEmpty
                            ? NetworkImage(_user!.profileImage)
                            : null,
                        child: _user!.profileImage.isEmpty
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // User Info
                      Text(
                        _user!.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${_user!.rating.toStringAsFixed(1)} (${_user!.totalReviews} reviews)',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Details Card
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                Icons.email,
                                'Email',
                                _user!.email,
                              ),
                              const Divider(),
                              _buildInfoRow(
                                Icons.phone,
                                'Phone',
                                _user!.phone,
                              ),
                              const Divider(),
                              _buildInfoRow(
                                Icons.location_on,
                                'Location',
                                _user!.location,
                              ),
                              const Divider(),
                              _buildInfoRow(
                                Icons.calendar_today,
                                'Member Since',
                                '${_user!.createdAt.day}/${_user!.createdAt.month}/${_user!.createdAt.year}',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Edit Profile Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit Profile'),
                            onPressed: () {
                              // Navigate to edit profile screen
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF667EEA),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Logout Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.logout),
                            label: const Text('Logout'),
                            onPressed: _logout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF667EEA), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
