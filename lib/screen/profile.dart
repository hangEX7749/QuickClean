import 'package:flutter/material.dart';
import 'package:quick_clean/state/user_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; 

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  Key _refreshKey = UniqueKey();
  Map<String, dynamic>? userData;


  void _handleRefresh() {
    setState(() {
      _refreshKey = UniqueKey(); // Changing the key forces a full reload
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async{
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .single();

      setState(() {
        userData = data;
      });

    _emailController.text = user.email ?? '';
    _nameController.text = userData?['username'] ?? '';

  }

  // Update Profile Name
  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      await supabase.auth.updateUser(
        UserAttributes(data: {'username': _nameController.text.trim()}),
      );

      await supabase
          .from('users')
          .update({'username': _nameController.text.trim()})
          .eq('id', supabase.auth.currentUser!.id);

      currentUserData.value = {
        ...currentUserData.value!,
        'username': _nameController.text,
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.profileUpdated), backgroundColor: Colors.green),
      );

      _handleRefresh();
      _loadUserData(); // Refresh local user data after update

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.profileUpdateFailed), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _refreshKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.viewProfile, style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.black12,
              child: Icon(Icons.person, size: 50, color: Colors.black),
            ),
            const SizedBox(height: 30),
            
            // Email (Read Only)
            TextField(
              controller: _emailController,
              enabled: false,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.email,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 20),

            // Name Field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.fullName,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 30),

            // Update Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(AppLocalizations.of(context)!.save, style: TextStyle(color: Colors.white)),
              ),
            ),
            
            const Divider(height: 60),

            // Change Password Trigger
            ListTile(
              leading: const Icon(Icons.lock_outline, color: Colors.blue),
              title: Text(AppLocalizations.of(context)!.changePassword),
              subtitle: Text(AppLocalizations.of(context)!.updateAccountSecurity),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showChangePasswordSheet(context),
            ),

            // Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(AppLocalizations.of(context)!.logout),
              subtitle: Text(AppLocalizations.of(context)!.signOutConfirmation),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- Password Change Modal ---
  void _showChangePasswordSheet(BuildContext context) {
    final passController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20, right: 20, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.changePassword, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: passController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.newPassword,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (passController.text.length < 6) return;
                  try {
                    await supabase.auth.updateUser(UserAttributes(password: passController.text));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password changed!")));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: Text(AppLocalizations.of(context)!.updatePassword, style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog( // renamed to innerContext for clarity
        title: Text(AppLocalizations.of(context)!.logout),
        content: Text(AppLocalizations.of(context)!.signOutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(innerContext), 
            child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              // Close the dialog first using its specific context
              Navigator.pop(innerContext);
              // Then call logout using the main page context
              _logout(context);
            }, 
            child: Text(AppLocalizations.of(context)!.logout, style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      // 1. Sign out from Supabase
      await Supabase.instance.client.auth.signOut();

      // 2. Use rootNavigator to ensure we break out of any dialogs/overlays
      if (!mounted) return; // Best practice: check if widget is still alive
      
      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
        '/', 
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out: $e")),
      );
    }
  }
}