import 'package:flutter/material.dart';
import '../../models/service_provider.dart';
import '../../services/auth_service.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  late AuthService _authService;
  ServiceProvider? _provider;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _loadProviderData();
  }

  Future<void> _loadProviderData() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final provider = await _authService.getProviderData(user.uid);
        setState(() {
          _provider = provider;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading provider: $e');
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
          : _provider == null
              ? const Center(child: Text('Error loading profile'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),

                      // Profile Picture
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            _provider!.profileImage.isNotEmpty
                                ? NetworkImage(
                                    _provider!.profileImage)
                                : null,
                        child: _provider!.profileImage
                                .isEmpty
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Provider Info
                      Text(
                        _provider!.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star,
                              color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${_provider!.rating.toStringAsFixed(1)} (${_provider!.totalReviews} reviews)',
                            style: const TextStyle(
                                color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${_provider!.hourlyRate}/hr',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF667EEA),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Approval Status
                      Card(
                        color: _provider!.isApproved
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(
                                _provider!.isApproved
                                    ? Icons.verified
                                    : Icons.hourglass_empty,
                                color: _provider!.isApproved
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _provider!.isApproved
                                      ? 'Approved Provider'
                                      : 'Awaiting Approval',
                                  style: TextStyle(
                                    color: _provider!.isApproved
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Details Card
                      Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Services',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: _provider!.services
                                    .map((service) =>
                                        Chip(
                                          label: Text(
                                            service,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          backgroundColor: const Color(
                                              0xFF667EEA)
                                              .withOpacity(
                                              0.2),
                                        ))
                                    .toList(),
                              ),
                              const Divider(height: 24),
                              _buildInfoRow(
                                Icons.email,
                                'Email',
                                _provider!.email,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.phone,
                                'Phone',
                                _provider!.phone,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.location_on,
                                'Location',
                                _provider!.location,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.work,
                                'Total Jobs',
                                '${_provider!.totalJobs}',
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.monetization_on,
                                'Total Earnings',
                                '\$${_provider!.totalEarnings.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Edit Profile Button
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16),
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
                              foregroundColor:
                                  const Color(0xFF667EEA),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Logout Button
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16),
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
    return Row(
      children: [
        Icon(icon,
            color: const Color(0xFF667EEA), size: 20),
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
    );
  }
}
