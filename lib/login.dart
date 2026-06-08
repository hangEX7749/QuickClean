// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:quick_clean/admin_screen/login.dart';
import 'package:quick_clean/main.dart';
import 'package:quick_clean/reset_password.dart';
import 'package:quick_clean/signup.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; 
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

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
      return AppLocalizations.of(context)!.emailError;
    }
    
    return null;
  }

  // Password validator function
  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.passwordError;
    }
    
    // if (value.length < 6) {
    //   return 'Password must be at least 6 characters';
    // }
    
    return null;
  }


  bool _isLoading = false;
  bool _isPasswordObscured = true;

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
        throw Exception(Text(AppLocalizations.of(context)!.loginFailed).data!);
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
      if (role == 'authenticated') {
        Navigator.pushReplacementNamed(context, '/member_home');
      } else {
        // If not member, show error and log out and return to login and prompt msg not exists
        await supabase.auth.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text(AppLocalizations.of(context)!.accountNotExist),
            backgroundColor: Colors.redAccent,
          ),
        );
        // Navigator.pushReplacementNamed(context, '/admin_home');
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

  Future<void> _signInWithGoogle() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: '938283211752-qb6njf4s497h999cm0rm8puqkljj3911.apps.googleusercontent.com', // ✅ Web Client ID only
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        Navigator.pop(context);
        setState(() => _isLoading = false);
        return; // user cancelled
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) throw Exception('No ID token from Google');

      final res = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = res.user;
      if (user == null) throw Exception('Supabase sign-in failed');

      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, '/member_home');

    } on AuthException catch (error) {
      Navigator.pop(context);
      _showErrorSnackBar(error.message);
            print(error);
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar("Google sign-in error: $e");
      print(e);
    }

    setState(() => _isLoading = false);
  }

  Future<void> _signInWithFacebook() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.facebook,
        // We will configure this custom deep link in Step 2!
        redirectTo: 'com.example.quickclean://login-callback', 
      );
    } catch (e) {
      _showErrorSnackBar("Facebook Sign-In failed: $e");
    }
  }

  @override
  void initState() {
    super.initState();

    // Listen for Auth changes, specifically for 'Password Recovery'
    supabase.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.passwordRecovery) {
        // The user clicked the email link! Take them to the new password page.
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
        );
      } else if (event == AuthChangeEvent.signedIn && session != null) {
        final user = session.user;
        
        final userData = await supabase
            .from('users')
            .select('role')
            .eq('id', user.id)
            .maybeSingle();

        String? role = userData?['role'];

        if (role == 'authenticated') {
          // Use mounted check because this is async inside a listener
          if (mounted) Navigator.pushReplacementNamed(context, '/member_home');
        } else {
          await supabase.auth.signOut();
          if (mounted) {
            _showErrorSnackBar(AppLocalizations.of(context)!.accountNotExist);
          }
        }
      }
    });
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
            Positioned(
              top: 40,
              right: 20,
              child: PopupMenuButton<Locale>(
                // We swap 'icon' for 'child' to combine the icon and text
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Keeps the row tight
                  children: [
                    Text(
                      AppLocalizations.of(context)!.changeLanguage, 
                      style: const TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.language, color: Colors.white),
                  ],
                ),
                onSelected: (Locale locale) {
                  MyApp.setLocale(context, locale);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: Locale('en'), child: Text(Localizations.localeOf(context).languageCode == 'en' ? "English (Current)" : "English")),
                  PopupMenuItem(value: Locale('zh'), child: Text(Localizations.localeOf(context).languageCode == 'zh' ? "中文 (Current)" : "中文")),
                  PopupMenuItem(value: Locale('my'), child: Text(Localizations.localeOf(context).languageCode == 'ms' ? "Bahasa Melayu (Current)" : "Bahasa Melayu")),
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
                              AppLocalizations.of(context)!.loginTitle, // 'loginTitle' must be in your .arb file
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            AppLocalizations.of(context)!.emailLabel, 
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
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: Text(AppLocalizations.of(context)!.emailHint).data, // 'emailHint' must be in your .arb file
                                prefixIcon: const Icon(Icons.email_outlined),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                errorStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            AppLocalizations.of(context)!.passwordLabel,
                          ),
                          const SizedBox(height: 5),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFececf8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextFormField(
                              // 1. Link this to your dynamic state variable
                              obscureText: _isPasswordObscured, 
                              controller: _passwordController,
                              validator: _validatePassword,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: Text(AppLocalizations.of(context)!.passwordHint).data, 
                                prefixIcon: const Icon(Icons.password_outlined),
                                
                                // 2. Add the dynamic suffixIcon to toggle visibility
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordObscured 
                                        ? Icons.visibility_off_outlined 
                                        : Icons.visibility_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordObscured = !_isPasswordObscured;
                                    });
                                  },
                                ),
                                
                                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                errorStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _showForgotPasswordDialog,
                              child: Text(
                                AppLocalizations.of(context)!.forgotPassword,
                                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                              ),
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
                                    AppLocalizations.of(context)!.login_button,
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
                          const SizedBox(height: 15),
                          const Row(
                            children: [
                              Expanded(child: Divider(thickness: 1)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text("OR", style: TextStyle(color: Colors.grey)),
                              ),
                              Expanded(child: Divider(thickness: 1)),
                            ],
                          ),
                          const SizedBox(height: 15),
                          OutlinedButton(
                            onPressed: _signInWithGoogle,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Standard Google Icon asset representation
                                Image.asset('images/google.png', height: 24), 
                                const SizedBox(width: 12),
                                const Text(
                                  'Sign in with Google',
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          // Place this right underneath your Google OutlinedButton inside the Column:
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: _signInWithFacebook,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.facebook, color: Colors.blue[800], size: 24),
                                const SizedBox(width: 12),
                                const Text(
                                  'Sign in with Facebook',
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.dontHaveAccount,
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
                                  AppLocalizations.of(context)!.signUp,
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
                                  MaterialPageRoute(builder: (context) => AdminLoginPage()),
                                );
                              },
                              child: Text(
                                 AppLocalizations.of(context)!.loginAsAdmin,
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

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.resetPassword),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.forgotPasswordInstruction),
            const SizedBox(height: 15),
            TextField(
              controller: resetEmailController,
              decoration: InputDecoration(
                labelText: Text(AppLocalizations.of(context)!.emailLabel).data,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isEmpty) return;

              try {
                await supabase.auth.resetPasswordForEmail(email);
                Navigator.pop(context); // Close dialog
                _showSnackBar(AppLocalizations.of(context)!.resetLinkSent, Colors.green);
              } catch (e) {
                _showSnackBar("Error: $e", Colors.red);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            child: Text(AppLocalizations.of(context)!.sendLink, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );


  }
}