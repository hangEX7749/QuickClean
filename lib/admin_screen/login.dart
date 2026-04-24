// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:quick_clean/login.dart';
import 'package:quick_clean/signup.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {

  String? email, password;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final supabase = Supabase.instance.client;

  
  // Email validator function
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    // Basic email format validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  // Password validator function
  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    
    // if (value.length < 6) {
    //   return 'Password must be at least 6 characters';
    // }
    
    return null;
  }


  bool _isLoading = false;

  Future<void> _signIn() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final res = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = res.user;

      if (user == null) {
        throw Exception("Login failed");
      }

      // ✅ Use user.id instead of email
      final userData = await supabase
          .from('users')
          .select('role')
          .eq('id', user.id)
          .maybeSingle(); // safer than single()

      // ✅ Default role if no record found
      String role = userData?['role'];

      Navigator.pop(context); // remove loading

      // ✅ Navigate based on role
      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin_home');
      } else {
        // If not admin, show error and log out and return to login and prompt msg not exists
        await supabase.auth.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No admin account found with these credentials."),
            backgroundColor: Colors.redAccent,
          ),
        );
      Navigator.pushReplacementNamed(context, '/admin_home');
      }

    } on AuthException catch (error) {
      Navigator.pop(context);
      _showErrorSnackBar(error.message);
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar("Unexpected error: $e");
    }

    setState(() => _isLoading = false);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 30),
              height: MediaQuery.of(context).size.height / 2.5,
              padding: const EdgeInsets.only(top: 10),
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 0, 0, 0),
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
            Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 3.6,
                  left: 20,
                  right: 20
              ),
              child: Material(
                elevation: 3.0,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  height: MediaQuery.of(context).size.height / 1.65,
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Center(
                            child: Text(
                              "Admin Log In",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Email",
                          ),
                          const SizedBox(height: 5),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFececf8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Enter your email",
                                prefixIcon: Icon(Icons.email_outlined),
                                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                errorStyle: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Password",
                          ),
                          const SizedBox(height: 5),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFececf8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextFormField(
                              obscureText: true,
                              controller: _passwordController,
                              validator: _validatePassword,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Enter your password",
                                prefixIcon: Icon(Icons.password_outlined),
                                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                errorStyle: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            // onTap: () {
                            //   Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (context) => const ForgotPasswordFront(),
                            //     ),
                            //   );
                            // },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Forgot Password?",
                                  // style: AppWidget.simpleTextFieldStyle().copyWith(
                                  //   color: Colors.blue, fontSize: 16,
                                  //   decoration: TextDecoration.underline,
                                  // ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                email = _emailController.text.trim();
                                password = _passwordController.text.trim();
                                _signIn();
                              }
                            },
                            child: Center(
                              child: Container(
                                width: 200,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    "Log In",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                //style: AppWidget.simpleTextFieldStyle(),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignUpPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "SignUp",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 16,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => LoginPage()),
                                );
                              },
                              child: const Text(
                                "Login as User",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}