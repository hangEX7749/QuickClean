// ignore_for_file: use_build_context_synchronously, deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:quick_clean/models/service_models.dart';
import 'package:quick_clean/screen/payment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; 

class BookingPage extends StatefulWidget {
  final String serviceName;
  final String serviceId;
  const BookingPage({super.key, required this.serviceName, required this.serviceId});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {

  final supabase = Supabase.instance.client;
  String? selectedProviderId; // Track the chosen provider
  List<Map<String, dynamic>> availableProviders = [];
  Map<String, dynamic>? serviceDetails;
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  String selectedTime = "10:00 AM";

  //Dump timeslot
  final List<String> timeSlots = [
    "10:00 AM", "11:00 AM", "12:00 PM",
    "1:00 PM", "2:00 PM", "3:00 PM",
    "4:00 PM", "5:00 PM"
  ];

  @override
  void initState() {
    super.initState();
    _fetchProviders(widget.serviceName);
  }

  //fetch service details
  Future<ServiceModel?> _fetchServiceDetails() async {
    try {
      final response = await supabase
          .from('services')
          .select()
          .eq('id', widget.serviceId)
          .single();


        setState(() {
          serviceDetails = response;
        });

      return ServiceModel.fromMap(response);
          
    } catch (e) {
      print("Exception fetching service details: $e");
      return null;
    }
  }

  //fetch service provider details
  Future<void> _fetchProviders(String serviceName) async {
    final data = await supabase
        .from('service_providers')
        .select()
        .eq('specialty', serviceName)
        .eq('is_available', true);

    setState(() {
      availableProviders = List<Map<String, dynamic>>.from(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("${AppLocalizations.of(context)!.book} ${widget.serviceName}"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.selectDate, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              Text(AppLocalizations.of(context)!.selectTime, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              const SizedBox(height: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.selectSpecialist, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 160,
                    child: availableProviders.isEmpty 
                      ? Center(child: Text(AppLocalizations.of(context)!.noSpecialist))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: availableProviders.length,
                          itemBuilder: (context, index) {
                            final provider = availableProviders[index];
                            bool isSelected = selectedProviderId == provider['id'];
        
                            return GestureDetector(
                              onTap: () => setState(() => selectedProviderId = provider['id']),
                              child: Container(
                                width: 130,
                                margin: const EdgeInsets.only(right: 15),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundImage: NetworkImage(provider['image_url'] ?? 'https://via.placeholder.com/150'),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      provider['name'],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                    Text("⭐ ${provider['rating']}", style: const TextStyle(fontSize: 10)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(AppLocalizations.of(context)!.price, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
        
              if (serviceDetails != null) 
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // inner space
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100, // background color
                      borderRadius: BorderRadius.circular(8), // optional rounded corners
                    ),
                    child: Text(
                      "${serviceDetails!['price']}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              else 
                FutureBuilder(
                  future: _fetchServiceDetails(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(color: Colors.black);
                    } else if (snapshot.hasError) {
                      return const Text("Failed to load price", style: TextStyle(color: Colors.red));
                    } else if (snapshot.hasData) {
                      return Text("${snapshot.data!.price}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              
              const SizedBox(height: 30),
        
              // Confirm Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => _proceedToPayment(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text(AppLocalizations.of(context)!.confirmBooking, 
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _proceedToPayment() {
    if (selectedProviderId == null) {
      _showSnackBar(AppLocalizations.of(context)!.selectSpecialist, Colors.orange);
      return;
    }

    // Pass all data to the Payment Page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          bookingData: {
            'service_type': widget.serviceName,
            'booking_date': selectedDate.toIso8601String().split('T')[0],
            'booking_time': selectedTime,
            'total_price': serviceDetails?['price'] ?? 0,
            'provider_id': selectedProviderId,
          },
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }
}