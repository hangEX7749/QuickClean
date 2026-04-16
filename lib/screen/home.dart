// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key}); 
  @override 
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<dynamic> users = [];
  bool isLoading = true;

  @override 
  void initState() { 
    super.initState(); 
  } 
  
  Future<void> _logout(BuildContext context) async {
    try {
      // 1. Sign out from Supabase
      await Supabase.instance.client.auth.signOut();

      // 2. Use rootNavigator to ensure we break out of any dialogs/overlays
      if (!mounted) return; // Best practice: check if widget is still alive
      
      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
        '/', 
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QuickClean', style: TextStyle(fontWeight: FontWeight.bold)),
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
              _contactIcon(Icons.phone, "Call", Colors.blue, 
                () => _launchURL('tel:+123456789')),
              
              _contactIcon(Icons.chat_bubble, "WhatsApp", Colors.green, 
                () => _launchURL('https://wa.me/123456789')),
              
              _contactIcon(Icons.email, "Email", Colors.redAccent, 
                () => _launchURL('mailto:info@clean.com')),

              // The Logout Button
              _contactIcon(Icons.logout, "Logout", Colors.black, 
                () => _showLogoutDialog(context)),
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

  Widget _contactIcon(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog( // renamed to innerContext for clarity
        title: const Text("Logout"),
        content: const Text("Are you sure you want to leave?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(innerContext), 
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              // Close the dialog first using its specific context
              Navigator.pop(innerContext);
              // Then call logout using the main page context
              _logout(context);
            }, 
            child: const Text("Logout", style: TextStyle(color: Colors.red))
          ),
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