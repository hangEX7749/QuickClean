import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingList extends StatefulWidget {
  const BookingList({super.key});

  @override
  State<BookingList> createState() => BookingListState();
}

class BookingListState extends State<BookingList> with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _allBookings = [];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
    _tabController = TabController(length: 4, vsync: this);
  }

Future<void> _fetchBookings() async {
  try {
    // Corrected the parenthesis: users(username, email)
    final data = await supabase
        .from('bookings')
        .select('''
          *,
          users (
            username,
            name
          )
        ''');

    setState(() {
      _allBookings = List<Map<String, dynamic>>.from(data);
      _isLoading = false;
    });
  } catch (e) {
    debugPrint("Error: $e");
    setState(() => _isLoading = false);
  }
}

  Future<void> _updateStatus(String bookingId, String newStatus) async {
    await supabase.from('bookings').update({'status': newStatus}).eq('id', bookingId);
    _fetchBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Bookings", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.black,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(text: "Pending"),
            Tab(text: "Confirmed"),
            Tab(text: "Completed"),
            Tab(text: "Cancelled"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBookingList("pending"),
                _buildBookingList("confirmed"),
                _buildBookingList("completed"),
                _buildBookingList("cancelled"),
              ],
            ),
    );
  }

  Widget _buildBookingList(String status) {
    final filtered = _allBookings.where((b) => b['status'] == status).toList();

    if (filtered.isEmpty) {
      return Center(child: Text("No $status bookings found."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final booking = filtered[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ExpansionTile(
            title: Text("${booking['service_type']} - ${booking['users']['username']} "),
            subtitle: Text("${booking['booking_date']} at ${booking['booking_time']}"),
            leading: _getStatusIcon(status),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text("Property Size: ${booking['property_size'] ?? 'N/A'}"),
                    Text("Total Price: \$${booking['total_price'] ?? '0.00'}"),
                    if (booking['notes'] != null) Text("Notes: ${booking['notes']}"),
                    const Divider(),
                    const Text("Change Status:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (status != 'confirmed') 
                          _statusButton(booking['id'], "confirmed", Colors.green),
                        if (status != 'completed') 
                          _statusButton(booking['id'], "completed", Colors.blue),
                        if (status != 'cancelled') 
                          _statusButton(booking['id'], "cancelled", Colors.red),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _statusButton(String id, String status, Color color) {
    return ElevatedButton(
      onPressed: () => _updateStatus(id, status),
      style: ElevatedButton.styleFrom(backgroundColor: color),
      child: Text(status.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white)),
    );
  }

  Widget _getStatusIcon(String status) {
    switch (status) {
      case 'pending': return const Icon(Icons.timer, color: Colors.orange);
      case 'confirmed': return const Icon(Icons.check_circle, color: Colors.green);
      case 'completed': return const Icon(Icons.done_all, color: Colors.blue);
      case 'cancelled': return const Icon(Icons.cancel, color: Colors.red);
      default: return const Icon(Icons.help_outline);
    }
  }
}