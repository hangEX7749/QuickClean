// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      _showSnackBar("Error: $e", Colors.red);
    }
  }

  Future<void> _deleteService(String id) async {
    await supabase.from('services').delete().eq('id', id);
    _fetchServices();
    _showSnackBar("Service deleted", Colors.black);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Services"), backgroundColor: Colors.white, foregroundColor: Colors.black),
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
        title: Text(isEditing ? "Edit Service" : "New Service"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Service Name")),
            TextField(controller: urlController, decoration: const InputDecoration(labelText: "Icon URL")),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
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
                _showSnackBar("Success!", Colors.green);
              } on PostgrestException catch (error) {
                // This will catch Supabase-specific errors (like RLS or Schema errors)
                _showSnackBar("Supabase Error: ${error.message}", Colors.red);
              } catch (e) {
                _showSnackBar("Unexpected Error: $e", Colors.red);
              }
            },
            child: Text(isEditing ? "Save Changes" : "Add"),
          )
        ],
      ),
    );
  }
  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }
}