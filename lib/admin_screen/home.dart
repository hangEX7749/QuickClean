// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:quick_clean/admin_screen/admin_list.dart';
import 'package:quick_clean/admin_screen/booking_list.dart';
import 'package:quick_clean/admin_screen/manage_service.dart';
import 'package:quick_clean/admin_screen/member_list.dart';
import 'package:quick_clean/admin_screen/service_provider.dart';
import 'package:quick_clean/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; 

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
        title: AppLocalizations.of(context)!.manageMembers,
        icon: Icons.person,
        onTap: () {
          // Replace with your member management page
          Navigator.push(context, MaterialPageRoute(builder: (_) => AdminMemberList()));
        },
      ),
      _AdminMenuItem(
        title: AppLocalizations.of(context)!.manageServiceProviders,
        icon: Icons.people,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceProvider()));
        },   // Replace with your service provider management page
      ),
      _AdminMenuItem(
        title: AppLocalizations.of(context)!.manageServices,
        icon: Icons.build,
        onTap: () {
          // Replace with your service management page
          Navigator.push(context, MaterialPageRoute(builder: (_) => AdminServicePage()));
        },
      ),
      _AdminMenuItem(
        title: AppLocalizations.of(context)!.manageBookings,
        icon: Icons.event_available,
        onTap: () {
          // Replace with your booking page
          Navigator.push(context, MaterialPageRoute(builder: (_) => BookingList()));
        },
      ),
      _AdminMenuItem(
        title: AppLocalizations.of(context)!.addNewAdmin,
        icon: Icons.admin_panel_settings,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AdminList()));
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.adminPanel, style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: AppLocalizations.of(context)!.logout,
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(AppLocalizations.of(context)!.logout),
                  content: Text(AppLocalizations.of(context)!.signOutConfirmation),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(AppLocalizations.of(context)!.logout),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await _logout(context);                
              }
            },
          ),
                   PopupMenuButton<Locale>(
            // Use 'child' instead of 'icon' to combine Text and Icon
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Icon(Icons.language, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.changeLanguage, // Localize this!
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            onSelected: (Locale locale) {
              MyApp.setLocale(context, locale);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: Locale('en'),
                child: Text("English"),
              ),
              const PopupMenuItem(
                value: Locale('zh'),
                child: Text("中文"),
              ),
              const PopupMenuItem(
                value: Locale('my'),
                child: Text("Bahasa Melayu"),
              ),
            ],
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
