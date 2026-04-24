// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:quick_clean/admin_screen/admin_list.dart';
import 'package:quick_clean/admin_screen/booking_list.dart';
import 'package:quick_clean/admin_screen/manage_service.dart';
import 'package:quick_clean/admin_screen/member_list.dart';
import 'package:quick_clean/admin_screen/service_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {

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

    final List<_AdminMenuItem> adminItems = [
      _AdminMenuItem(
        title: "Manage Members",
        icon: Icons.person,
        onTap: () {
          // Replace with your member management page
          Navigator.push(context, MaterialPageRoute(builder: (_) => AdminMemberList()));
        },
      ),
      _AdminMenuItem(
        title: "Manage Service Providers",
        icon: Icons.people,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceProvider()));
        },   // Replace with your service provider management page
      ),
      _AdminMenuItem(
        title: "Manage Services",
        icon: Icons.build,
        onTap: () {
          // Replace with your service management page
          Navigator.push(context, MaterialPageRoute(builder: (_) => AdminServicePage()));
        },
      ),
      _AdminMenuItem(
        title: "Manage Bookings",
        icon: Icons.event_available,
        onTap: () {
          // Replace with your booking page
          Navigator.push(context, MaterialPageRoute(builder: (_) => BookingList()));
        },
      ),
      _AdminMenuItem(
        title: "Add New Admin",
        icon: Icons.admin_panel_settings,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AdminList()));
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Panel", style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Confirm Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await _logout(context);                
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: adminItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 columns
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final item = adminItems[index];
            return GestureDetector(
              onTap: item.onTap,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, size: 40, color: Colors.deepPurple),
                    const SizedBox(height: 10),
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AdminMenuItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  _AdminMenuItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}
