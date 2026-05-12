// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; 

class EditServiceProvider extends StatefulWidget {
  final Map<String, dynamic> provider;
  const EditServiceProvider({super.key, required this.provider});

  @override
  State<EditServiceProvider> createState() => _EditServiceProviderState();
}

class _EditServiceProviderState extends State<EditServiceProvider> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _specialtyController;
  late bool _isAvailable;
  late List<String> _availableServices;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.provider['name']);
    _emailController = TextEditingController(text: widget.provider['email']);
    _phoneController = TextEditingController(text: widget.provider['phone']);
    _specialtyController = TextEditingController(text: widget.provider['specialty']);
    _isAvailable = widget.provider['is_available'] ?? true;
    _availableServices = [];
    _fetchAvailableServices();
  }

  Future<void> _fetchAvailableServices() async {
    final data = await Supabase.instance.client.from('services').select('name');
    setState(() {
      _availableServices = List<String>.from(data.map((s) => s['name']));
    });
  }

  Future<void> _update() async {
    await Supabase.instance.client.from('service_providers').update({
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'specialty': _specialtyController.text,
      'is_available': _isAvailable,
    }).eq('id', widget.provider['id']);
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.editServiceProvider, style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.fullName)),
            const SizedBox(height: 15),
            TextField(controller: _emailController, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.email)),
            const SizedBox(height: 15),
            TextField(controller: _phoneController, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.phone)),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _availableServices.contains(_specialtyController.text) 
                    ? _specialtyController.text 
                    : null,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.specialty, border: OutlineInputBorder()),
              items: _availableServices.map((service) {
                return DropdownMenuItem(value: service, child: Text(service));
              }).toList(),
              onChanged: (val) => setState(() => _specialtyController.text = val!),
            ),
            const SizedBox(height: 15),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.availableForBooking),
              value: _isAvailable,
              onChanged: (val) => setState(() => _isAvailable = val),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _update,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: Text(AppLocalizations.of(context)!.save, style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}