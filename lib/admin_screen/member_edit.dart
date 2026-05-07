// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MemberEditPage extends StatefulWidget {
  final Map<String, dynamic> member;
  const MemberEditPage({super.key, required this.member});

  @override
  State<MemberEditPage> createState() => _MemberEditPageState();
}

class _MemberEditPageState extends State<MemberEditPage> {
  late TextEditingController _nameController;
  late String _selectedRole;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member['username']);
    _selectedRole = widget.member['role'] ?? 'authenticated';
  }

  Future<void> _updateMember() async {
    setState(() => _isSaving = true);
    try {
      await Supabase.instance.client
          .from('users')
          .update({
            'username': _nameController.text.trim(),
            'role': _selectedRole,
          })
          .eq('id', widget.member['id']);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Member updated successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: $e")),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Member")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(labelText: "Account Role", border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'authenticated', child: Text("Member")),
                DropdownMenuItem(value: 'admin', child: Text("Admin")),
              ],
              onChanged: (val) => setState(() => _selectedRole = val!),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _updateMember,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("Save Changes", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}