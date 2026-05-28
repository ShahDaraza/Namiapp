import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';

class ProviderJobsScreen extends StatefulWidget {
  const ProviderJobsScreen({Key? key}) : super(key: key);

  @override
  State<ProviderJobsScreen> createState() => _ProviderJobsScreenState();
}

class _ProviderJobsScreenState extends State<ProviderJobsScreen> {
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
    final user = _authService.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not authenticated')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Requests'),
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
                _buildFilterChip('Accepted', 'accepted'),
                _buildFilterChip('In Progress', 'inProgress'),
                _buildFilterChip('Completed', 'completed'),
              ],
            ),
          ),
          // Jobs List
          Expanded(
            child: StreamBuilder<List<Booking>>(
              stream: _firestoreService.getProviderBookings(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.work_off,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No jobs available'),
                      ],
                    ),
                  );
                }

                var bookings = snapshot.data!;

                // Apply filter
                if (_filterStatus != 'all') {
                  bookings = bookings
                      .where((b) =>
                          b.status.toString().split('.').last ==
                          _filterStatus)
                      .toList();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return _buildJobCard(context, booking);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
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

  Widget _buildJobCard(BuildContext context, Booking booking) {
    final statusColor = _getStatusColor(booking.status);
    final statusText = booking.status.toString().split('.').last.toUpperCase();

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
                Text(
                  booking.serviceType,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              booking.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    booking.location,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${booking.scheduledTime.day}/${booking.scheduledTime.month}/${booking.scheduledTime.year} at ${booking.scheduledTime.hour}:${booking.scheduledTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${booking.estimatedCost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667EEA),
                  ),
                ),
                if (booking.status == BookingStatus.pending)
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _handleJobAction(booking, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Accept',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _handleJobAction(booking, false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Decline',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                  )
                else if (booking.status == BookingStatus.accepted)
                  ElevatedButton(
                    onPressed: () =>
                        _updateBookingStatus(booking, BookingStatus.inProgress),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('Start Work',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  )
                else if (booking.status == BookingStatus.inProgress)
                  ElevatedButton(
                    onPressed: () =>
                        _updateBookingStatus(booking, BookingStatus.completed),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Complete',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleJobAction(Booking booking, bool accept) async {
    try {
      if (accept) {
        await _firestoreService.updateBookingStatus(
            booking.id, BookingStatus.accepted);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job accepted!')),
        );
      } else {
        await _firestoreService.cancelBooking(
            booking.id, 'Provider declined the job');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job declined')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateBookingStatus(
      Booking booking, BookingStatus status) async {
    try {
      await _firestoreService.updateBookingStatus(booking.id, status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Job status updated to ${status.toString().split('.').last}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.accepted:
        return Colors.blue;
      case BookingStatus.inProgress:
        return Colors.purple;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }
}
