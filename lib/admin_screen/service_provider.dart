// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:quick_clean/admin_screen/service_provider_edit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; 

class ServiceProvider extends StatefulWidget {
  const ServiceProvider({super.key});

  @override
  State<ServiceProvider> createState() => _ServiceProviderState();
}

class _ServiceProviderState extends State<ServiceProvider> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _providers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProviders();
  }

  Future<void> _fetchProviders() async {
    final data = await supabase.from('service_providers').select().order('name');
    setState(() {
      _providers = List<Map<String, dynamic>>.from(data);
      _isLoading = false;
    });
  }

  // 1. Function to show the Create Dialog
  void _showCreateDialog() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String? selectedSpecialty;
    List<String> serviceNames = [];

    // 1. Fetch available services for the dropdown
    try {
      final serviceData = await supabase.from('services').select('name');
      serviceNames = List<String>.from(serviceData.map((s) => s['name']));
    } catch (e) {
      debugPrint("Error fetching services: $e");
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder( // Needed to update dropdown state inside dialog
        builder: (context, setDialogState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.newServiceProvider),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.fullName)),
                TextField(controller: emailController, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.email)),
                const SizedBox(height: 15),
                
                // 2. Dropdown for Specialty
                DropdownButtonFormField<String>(
                  value: selectedSpecialty,
                  hint: Text(AppLocalizations.of(context)!.selectSpecialty),
                  items: serviceNames.map((name) {
                    return DropdownMenuItem(value: name, child: Text(name));
                  }).toList(),
                  onChanged: (val) {
                    setDialogState(() => selectedSpecialty = val);
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: () async {
                if (nameController.text.isNotEmpty && selectedSpecialty != null) {
                  await supabase.from('service_providers').insert({
                    'name': nameController.text.trim(),
                    'email': emailController.text.trim(),
                    'specialty': selectedSpecialty,
                    'is_available': true,
                  });
                  Navigator.pop(context);
                  _fetchProviders();
                }
              },
              child: Text(AppLocalizations.of(context)!.create),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.serviceProviders, style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      // 2. Add the Floating Action Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: _showCreateDialog,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.black)) 
        : ListView.builder(
            itemCount: _providers.length,
            itemBuilder: (context, index) {
              final item = _providers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.black, child: Icon(Icons.person, color: Colors.white)),
                  title: Text(item['name']),
                  subtitle: Text(item['specialty'] ?? "NULL"),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditServiceProvider(provider: item)),
                    ).then((_) => _fetchProviders());
                  },
                ),
              );
            },
          ),
    );
  }
}