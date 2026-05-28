import 'package:flutter/material.dart';
import '../../models/service_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';

class AdminProvidersScreen extends StatefulWidget {
  const AdminProvidersScreen({Key? key}) : super(key: key);

  @override
  State<AdminProvidersScreen> createState() => _AdminProvidersScreenState();
}

class _AdminProvidersScreenState extends State<AdminProvidersScreen> {
  late FirestoreService _firestoreService;
  late AuthService _authService;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    _authService = AuthService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Providers'),
        backgroundColor: const Color(0xFF667EEA),
      ),
      body: Column(
        children: [
          // Filter tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                _buildFilterChip('Pending', 'pending'),
                _buildFilterChip('Approved', 'approved'),
              ],
            ),
          ),
          // Providers List
          Expanded(
            child: FutureBuilder<List<ServiceProvider>>(
              future: _filterStatus == 'pending'
                  ? _firestoreService.getUnapprovedProviders()
                  : _loadAllProviders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No providers'),
                      ],
                    ),
                  );
                }

                final providers = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: providers.length,
                  itemBuilder: (context, index) {
                    final provider = providers[index];
                    return _buildProviderCard(context, provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<ServiceProvider>> _loadAllProviders() async {
    // In a real app, you'd load all providers
    return [];
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _filterStatus = value);
        },
        backgroundColor: Colors.grey[200],
        selectedColor: const Color(0xFF667EEA),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildProviderCard(
      BuildContext context, ServiceProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        provider.email,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        provider.services.join(', '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        provider.isApproved ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    provider.isApproved ? 'APPROVED' : 'PENDING',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('${provider.rating} (${provider.totalReviews})'),
                  ],
                ),
                Text('\$${provider.hourlyRate}/hr'),
              ],
            ),
            const SizedBox(height: 12),
            if (!provider.isApproved)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _approveProvider(provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Approve',
                          style: TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _rejectProvider(provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Reject',
                          style: TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _approveProvider(ServiceProvider provider) async {
    try {
      await _firestoreService.approveProvider(provider.id);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Provider approved!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _rejectProvider(ServiceProvider provider) async {
    try {
      await _firestoreService.rejectProvider(provider.id);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Provider rejected')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}
