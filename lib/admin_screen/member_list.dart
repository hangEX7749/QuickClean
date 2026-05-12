// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:quick_clean/admin_screen/member_edit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; 

class AdminMemberList extends StatefulWidget {
  const AdminMemberList({super.key});

  @override
  State<AdminMemberList> createState() => _AdminMemberListState();
}

class _AdminMemberListState extends State<AdminMemberList> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _allMembers = [];
  List<Map<String, dynamic>> _filteredMembers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    try {
      final data = await supabase
          .from('users')
          .select()
          .filter('role', 'eq', 'authenticated')
          .order('name', ascending: true);

      setState(() {
        _allMembers = List<Map<String, dynamic>>.from(data);
        _filteredMembers = _allMembers;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.supabaseError.replaceAll('\$e', e.toString())), backgroundColor: Colors.red),
      );
    }
  }

  void _filterSearch(String query) {
    setState(() {
      _filteredMembers = _allMembers
          .where((user) =>
              user['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
              user['email'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.manageMembers, style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterSearch,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchByNameOrEmail,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // Member List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.black))
                : _filteredMembers.isEmpty
                    ? Center(child: Text(AppLocalizations.of(context)!.noMembersFound))
                    : ListView.builder(
                        itemCount: _filteredMembers.length,
                        itemBuilder: (context, index) {
                          final member = _filteredMembers[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.black,
                                child: Text(member['username'].toString().substring(0, 1).toUpperCase(), 
                                  style: const TextStyle(color: Colors.white)),
                              ),
                              title: Text(member['username'] ?? 'No Name'),
                              subtitle: Text(member['email']),
                              trailing: const Icon(Icons.edit_outlined),
                              onTap: () {
                                // Redirect to Edit Page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MemberEditPage(member: member),
                                  ),
                                ).then((_) => _fetchMembers()); // Refresh list when back
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}