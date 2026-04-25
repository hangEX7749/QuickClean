// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserBookingsPage extends StatefulWidget {
  const UserBookingsPage({super.key});

  @override
  State<UserBookingsPage> createState() => _UserBookingsPageState();
}

class _UserBookingsPageState extends State<UserBookingsPage> {
  final supabase = Supabase.instance.client;
  Key _refreshKey = UniqueKey();

  void _handleRefresh() {
    setState(() {
      _refreshKey = UniqueKey(); // Changing the key forces a full reload
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text("My Bookings", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Upcoming"),
              Tab(text: "History"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBookingList(['pending', 'confirmed']), // Upcoming
            _buildBookingList(['completed', 'cancelled']), // History
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(List<String> statuses) {
    final userId = supabase.auth.currentUser?.id;

    return FutureBuilder<List<Map<String, dynamic>>>(
      key: _refreshKey, // Re-fetches whenever _handleRefresh is called
      future: supabase
          .from('bookings')
          .select()
          .eq('user_id', userId ?? '')
          .filter('status', 'in', statuses) // Filter directly in the query
          .order('booking_date', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.black));
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final bookings = snapshot.data ?? [];

        if (bookings.isEmpty) {
          return const Center(child: Text("No bookings found."));
        }

        return RefreshIndicator(
          onRefresh: () async => _handleRefresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: bookings.length,
            itemBuilder: (context, index) => _bookingCard(bookings[index]),
          ),
        );
      },
    );
  }

  Widget _bookingCard(Map<String, dynamic> booking) {
    Color statusColor = booking['status'] == 'confirmed' ? Colors.green : Colors.orange;
    if (booking['status'] == 'cancelled') statusColor = Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking['service_type'],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking['status'].toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 25),
            Row(
              children: [
                const Icon(Icons.calendar_month, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(booking['booking_date']),
                const SizedBox(width: 20),
                const Icon(Icons.access_time, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(booking['booking_time']),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total: \$${booking['total_price']}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (booking['status'] == 'pending' || booking['status'] == 'confirmed')
                  TextButton(
                    onPressed: () => _cancelBooking(booking['id']),
                    child: const Text("Cancel Booking", style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelBooking(String bookingId) async {
    // 1. Show a quick confirmation dialog
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Booking?"),
        content: const Text("Are you sure you want to cancel this service?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // 2. Perform the update
      await supabase
          .from('bookings')
          .update({'status': 'cancelled'})
          .eq('id', bookingId);

      _handleRefresh();
      
      // 3. Success Feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking cancelled successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

}