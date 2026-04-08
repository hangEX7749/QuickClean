import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QuickClean'),
        actions: [IconButton(icon: Icon(Icons.notifications), onPressed: () {})],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello! Which service do you need?', 
                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _serviceCard('Home Cleaning', Icons.home, Colors.blue),
                  _serviceCard('Office Cleaning', Icons.business, Colors.green),
                  _serviceCard('Window Wash', Icons.wb_sunny, Colors.orange),
                  _serviceCard('Carpet Steam', Icons.layers, Colors.purple),
                ],
              ),
            ),
          ],
        ),
      ),
      // Using BottomAppBar instead of BottomNavigationBar for custom layouts
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Container(
          height: 60.0,
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Phone Call
              IconButton(
                icon: Icon(Icons.phone, color: Colors.blue),
                onPressed: () => _launchURL('tel:+123456789'),
              ),
              
              // WhatsApp
              IconButton(
                icon: Icon(Icons.chat_bubble_outline, color: Colors.green),
                onPressed: () => _launchURL('https://wa.me/123456789'),
              ),
              
              // Email
              IconButton(
                icon: Icon(Icons.email, color: Colors.redAccent),
                onPressed: () => _launchURL('mailto:support@cleaningservice.com'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _serviceCard(String title, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          SizedBox(height: 10),
          Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}