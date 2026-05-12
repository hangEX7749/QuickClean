// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; 

class AdminServicePage extends StatefulWidget {
  const AdminServicePage({super.key});

  @override
  State<AdminServicePage> createState() => _AdminServicePageState();
}

class _AdminServicePageState extends State<AdminServicePage> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _services = [];

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    try {
      final data = await supabase.from('services').select().order('name');
      setState(() {
        _services = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      _showSnackBar(AppLocalizations.of(context)!.errorFetchingServices, Colors.red);
    }
  }

  Future<void> _deleteService(String id) async {
    await supabase.from('services').delete().eq('id', id);
    _fetchServices();
    _showSnackBar(AppLocalizations.of(context)!.serviceDeleted, Colors.black);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.manageServices), backgroundColor: Colors.white, foregroundColor: Colors.black),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () => _showServiceDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : ListView.builder(
            itemCount: _services.length,
            itemBuilder: (context, index) {
            final service = _services[index];
            return ListTile(
              leading: Image.network(
                service['image_url'], 
                width: 40, 
                errorBuilder: (c, e, s) => const Icon(Icons.broken_image)
              ),
              title: Text(service['name']),
              subtitle: Text("\$${service['price']}"),
              trailing: Row( // Use a Row to hold two buttons
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                    onPressed: () => _showServiceDialog(service: service), // Pass the data!
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteService(service['id']),
                  ),
                ],
              ),
            );
          },
    ));
  }

  // Dialog to Add/Edit Service
  void _showServiceDialog({Map<String, dynamic>? service}) {
    final isEditing = service != null;
    
    // Pre-fill controllers if we are editing
    final nameController = TextEditingController(text: isEditing ? service['name'] : "");
    final urlController = TextEditingController(text: isEditing ? service['image_url'] : "");
    final priceController = TextEditingController(text: isEditing ? service['price'].toString() : "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? AppLocalizations.of(context)!.editService : AppLocalizations.of(context)!.newService),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.serviceName)),
            TextField(controller: urlController, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.iconURL)),
            TextField(controller: priceController, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.price), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
          ElevatedButton(
            onPressed: () async {
            try {
                final data = {
                  'name': nameController.text,
                  'image_url': urlController.text,
                  'price': double.tryParse(priceController.text) ?? 0,
                };

                if (isEditing) {
                  await supabase.from('services').update(data).eq('id', service['id']);
                } else {
                  await supabase.from('services').insert(data);
                }

                Navigator.pop(context);
                _fetchServices();
                _showSnackBar(AppLocalizations.of(context)!.serviceUpdated, Colors.green);
              } on PostgrestException {
                // This will catch Supabase-specific errors (like RLS or Schema errors)
                _showSnackBar(AppLocalizations.of(context)!.supabaseError, Colors.red);
              } catch (e) {
                _showSnackBar(AppLocalizations.of(context)!.unexpectedError, Colors.red);
              }
            },
            child: Text(isEditing ? AppLocalizations.of(context)!.saveChanges : AppLocalizations.of(context)!.add),
          )
        ],
      ),
    );
  }
  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }
}