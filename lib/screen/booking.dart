import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingPage extends StatefulWidget {
  final String serviceName;
  const BookingPage({super.key, required this.serviceName});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  String selectedTime = "10:00 AM";

  //Dump timeslot
  final List<String> timeSlots = [
    "10:00 AM", "11:00 AM", "12:00 PM",
    "1:00 PM", "2:00 PM", "3:00 PM",
    "4:00 PM", "5:00 PM"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Book ${widget.serviceName}"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Date", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            // Date Picker Trigger
            InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (picked != null) setState(() => selectedDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                        style: const TextStyle(fontSize: 16)),
                    const Icon(Icons.calendar_today, size: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Text("Select Time", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // Time Slots Grid
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: timeSlots.map((time) {
                bool isSelected = selectedTime == time;
                return ChoiceChip(
                  label: Text(time),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => selectedTime = time);
                  },
                  selectedColor: Colors.black,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  backgroundColor: Colors.grey.shade100,
                );
              }).toList(),
            ),

            const Spacer(),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => _confirmBooking(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("Confirm Booking", 
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmBooking() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      _showSnackBar("Please log in to book a service", Colors.red);
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.black)),
    );

    try {
      await supabase.from('bookings').insert({
        'user_id': user.id,
        'service_type': widget.serviceName,
        'booking_date': selectedDate.toIso8601String(), // Format as YYYY-MM-DD
        'booking_time': selectedTime,
        'status': 'pending',
      });

      Navigator.pop(context); // Remove loading indicator

      _showSuccessDialog();
    } catch (e) {
      Navigator.pop(context); // Remove loading indicator
      _showSnackBar("Booking failed: $e", Colors.red);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.check_circle, color: Colors.green, size: 50),
        content: const Text("Booking Successful!\nWe will contact you shortly.", textAlign: TextAlign.center),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Back to Home
              },
              child: const Text("Done", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            ),
          )
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }
}