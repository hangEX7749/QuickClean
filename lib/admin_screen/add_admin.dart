// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddAdminPage extends StatefulWidget {
  const AddAdminPage({super.key});

  @override
  State<AddAdminPage> createState() => _AddAdminPageState();
}

class _AddAdminPageState extends State<AddAdminPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;

    try {
      // 1. Sign up the user in Supabase Auth
      // Note: By default, this logs the app into the NEW user. 
      // To prevent this in a real production app, you would use a Supabase Edge Function.
      final AuthResponse res = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {
          'name': _nameController.text.trim(),
          'username': _nameController.text.trim(),
          'role': 'admin', // Metadata is passed here
        },
      );

      if (res.user != null) {
        // 2. Insert into your public.users table
        await supabase.from('users').upsert({
          'id': res.user!.id,
          'name': _nameController.text.trim(),
          'username' : _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'role': 'admin',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Admin account created successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
              print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Admin")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? "Enter a name" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email Address", border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? "Enter an email" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()),
                validator: (val) => val!.length < 6 ? "Minimum 6 characters" : null,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createAdmin,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("Create Admin Account", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}