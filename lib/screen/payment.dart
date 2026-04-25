// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> bookingData;
  const PaymentPage({super.key, required this.bookingData});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final supabase = Supabase.instance.client;
  bool _isProcessing = false;

  Future<void> _processPaymentAndBooking() async {
    setState(() => _isProcessing = true);

    // Mocking a payment delay
    await Future.delayed(const Duration(seconds: 2));

    try {
      final userId = supabase.auth.currentUser?.id;
      
      // Perform the ACTUAL insert here
      await supabase.from('bookings').insert({
        'user_id': userId,
        'service_type': widget.bookingData['service_type'],
        'booking_date': widget.bookingData['booking_date'],
        'booking_time': widget.bookingData['booking_time'],
        'total_price': widget.bookingData['total_price'],
        'provider_id': widget.bookingData['provider_id'],
        'status': 'pending', 
      });

      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving booking: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.bookingData['total_price'];

    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: ListTile(
                title: const Text("Total Amount"),
                trailing: Text("\$$price", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPaymentAndBooking,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: _isProcessing 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Pay Now & Confirm", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: const Text("Payment Successful!\nYour booking is now confirmed."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text("Back to Home"),
          )
        ],
      ),
    );
  }
}