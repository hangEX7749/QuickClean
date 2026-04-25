import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool _isLoading = false;

  Future<void> _updatePassword() async {
    if (_passwordController.text.length < 6) {
      _showSnackBar("Password must be at least 6 characters", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Supabase automatically handles the 'recovery' session from the email link
      await supabase.auth.updateUser(
        UserAttributes(password: _passwordController.text.trim()),
      );

      _showSuccessDialog();
    } catch (e) {
      _showSnackBar("Failed to update: $e", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Password")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text("Enter your new secure password below."),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updatePassword,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Update & Login", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper methods for SnackBar and Success Dialog...
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Password Updated"),
        content: const Text("Your password has been updated successfully! Please log in with your new password."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            child: const Text("Go to Login"),
          )
        ],
      ),
    );
  }
}