// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; 

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
        SnackBar(content: Text(AppLocalizations.of(context)!.memberUpdated), backgroundColor: Colors.black),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.supabaseError.replaceAll('\$e', e.toString())), backgroundColor: Colors.red),
      );
 
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.editMember)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.fullName, border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.accountRole, border: OutlineInputBorder()),
              items: [
                DropdownMenuItem(value: 'authenticated', child: Text(AppLocalizations.of(context)!.member)),
                DropdownMenuItem(value: 'admin', child: Text(AppLocalizations.of(context)!.admin)),
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
                  : Text(AppLocalizations.of(context)!.saveChanges, style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}