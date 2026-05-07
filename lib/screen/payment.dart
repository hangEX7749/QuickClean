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
      backgroundColor: Colors.grey.shade50, // Subtle background color
      appBar: AppBar(
        title: const Text("Checkout", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Order Summary", 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  
                  // Detailed Order Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _summaryRow("Service", "${widget.bookingData['service_type']}"),
                        const Divider(height: 30),
                        _summaryRow("Date", "${widget.bookingData['booking_date']}"),
                        const SizedBox(height: 10),
                        _summaryRow("Time", "${widget.bookingData['booking_time']}"),
                        const Divider(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Total Amount", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("\$$price", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // const SizedBox(height: 30),
                  // const Text("Payment Method", 
                  //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  // const SizedBox(height: 15),
                  
                  // Mock Payment Methods
                  // _paymentMethodTile("Credit Card", Icons.credit_card, Colors.orange, true),
                  // _paymentMethodTile("Apple Pay", Icons.apple, Colors.black, false),
                  // _paymentMethodTile("PayPal", Icons.account_balance_wallet, Colors.blue, false),
                ],
              ),
            ),
          ),
          
          // Bottom Action Bar (Laravel style "Sticky" footer)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 14, color: Colors.grey),
                    SizedBox(width: 5),
                    Text("Secure SSL Encrypted Payment", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _processPaymentAndBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isProcessing 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Confirm & Pay Now", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _summaryRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      ],
    );
  }

  // Widget _paymentMethodTile(String title, IconData icon, Color color, bool isSelected) {
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 10),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade200, width: 2),
  //     ),
  //     child: ListTile(
  //       leading: Icon(icon, color: color),
  //       title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
  //       trailing: isSelected 
  //           ? const Icon(Icons.check_circle, color: Colors.blue) 
  //           : const Icon(Icons.circle_outlined, color: Colors.grey),
  //     ),
  //   );
  // }
  
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