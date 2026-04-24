// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:quick_clean/admin_screen/add_admin.dart';
import 'package:quick_clean/admin_screen/member_edit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminList extends StatefulWidget {
  const AdminList({super.key});

  @override
  State<AdminList> createState() => _AdminListState();
}

class _AdminListState extends State<AdminList> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _allMembers = [];
  List<Map<String, dynamic>> _filteredMembers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAdmin();
  }

  Future<void> _fetchAdmin() async {
    try {
      final data = await supabase
          .from('users')
          .select()
          .filter('role', 'eq', 'admin')
          .order('name', ascending: true);

      setState(() {
        _allMembers = List<Map<String, dynamic>>.from(data);
        _filteredMembers = _allMembers;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching admins: $e")),
      );
      
        print(e.toString());
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
        title: const Text("Manage Admin", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => AddAdminPage()
        )).then((_) => _fetchAdmin()),
        child: const Icon(Icons.person_add, color: Colors.white),
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
                hintText: "Search by name or email...",
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
                    ? const Center(child: Text("No Admin found."))
                    : ListView.builder(
                        itemCount: _filteredMembers.length,
                        itemBuilder: (context, index) {
                          final member = _filteredMembers[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.black,
                                child: Text(member['name'][0].toUpperCase(), 
                                  style: const TextStyle(color: Colors.white)),
                              ),
                              title: Text(member['name'] ?? 'No Name'),
                              subtitle: Text(member['email'])
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