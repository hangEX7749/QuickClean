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
                leading: Image.network(service['image_url'], width: 40, errorBuilder: (c, e, s) => const Icon(Icons.broken_image)),
                title: Text(service['name']),
                subtitle: Text("\$${service['price']}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deleteService(service['id']),
                ),
              );
            },
          ),
    );
  }

  // Dialog to Add/Edit Service
  void _showServiceDialog() {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Service"),
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
              await supabase.from('services').insert({
                'name': nameController.text,
                'image_url': urlController.text,
                'price': double.tryParse(priceController.text) ?? 0,
              });
              Navigator.pop(context);
              _fetchServices();
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }
}