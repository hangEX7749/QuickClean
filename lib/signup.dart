// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; 

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final supabase = Supabase.instance.client;
  final bool _isLoading = false;

  bool _isAccepted = false; // For Terms & Conditions

  Future<void> _signUp() async {

    if (_isLoading) return;
    
    if (!_isAccepted) {
      _showErrorSnackBar(AppLocalizations.of(context)!.termsAndConditionsError);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. Create user in Supabase Auth
      final AuthResponse res = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {
          'name': _nameController.text.trim(),
          'username': _nameController.text.trim(),
          'role': 'authenticated', // Set role in user_metadata
        }
      );

      final User? user = res.user;

      if (user != null) {
        // 2. Insert into your custom 'user' table with role 'member'
        await supabase.from('users').upsert({
          'id': user.id,
          'email': _emailController.text.trim(),
          'name': _nameController.text.trim(),
          'username' : _nameController.text.trim(),
          'role': 'authenticated', 
        });

        Navigator.pop(context); // Close loading
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.registrationSuccess)),
        );
        
        Navigator.pop(context); // Return to Login Page
      }
    } on AuthException catch (error) {
      Navigator.pop(context);
      // ignore: avoid_print
      print('Auth error: ${error.message}');
      _showErrorSnackBar(error.message);
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar(AppLocalizations.of(context)!.registrationError);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Top Black Section
          Container(
            margin: const EdgeInsets.only(top: 10),
            height: MediaQuery.of(context).size.height / 3,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            
            child: Column(
              children: [
                Image.asset(
                  "images/logo.png",
                  height: 180,
                  fit: BoxFit.fill,
                  width: 240,
                ),
              ],
            ),
          ),
          
          // White Form Container
          Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height / 4.5, 
              left: 20, 
              right: 20,
              bottom: 20
            ),
            child: Material(
              elevation: 5.0,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Center(child: Text(AppLocalizations.of(context)!.signUp, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                        const SizedBox(height: 20),
                        
                        _label("Full Name"),
                        _inputField(_nameController, "John Doe", Icons.person_outline, false),
                        
                        const SizedBox(height: 15),
                        _label("Email Address"),
                        _inputField(_emailController, "example@mail.com", Icons.email_outlined, false),
                        
                        const SizedBox(height: 15),
                        _label("Password"),
                        _inputField(_passwordController, "••••••••", Icons.lock_outline, true),
                        
                        const SizedBox(height: 15),
                        
                        // Terms and Conditions Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _isAccepted,
                              onChanged: (val) => setState(() => _isAccepted = val!),
                              activeColor: Colors.black,
                            ),
                            Expanded(
                              child: Text(AppLocalizations.of(context)!.termsAndConditions, style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        
                        // Register Button
                        GestureDetector(
                          onTap: () {
                            if (_formKey.currentState!.validate()) _signUp();
                          },
                          child: Center(
                            child: Container(
                              width: 220,
                              height: 55,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(AppLocalizations.of(context)!.signUp, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Navigate back to Login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(AppLocalizations.of(context)!.alreadyHaveAccount, style: TextStyle(fontSize: 12)),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(AppLocalizations.of(context)!.login_button, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
  );

  Widget _inputField(TextEditingController controller, String hint, IconData icon, bool isPassword) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFececf8), borderRadius: BorderRadius.circular(10)),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: (value) => value!.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          prefixIcon: Icon(icon),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }
}