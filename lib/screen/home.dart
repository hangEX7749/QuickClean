// ignore_for_file: use_build_context_synchronously, deprecated_member_use, avoid_print
import 'package:flutter/material.dart';
import 'package:quick_clean/models/service_models.dart';
import 'package:quick_clean/models/service_provider_model.dart';
import 'package:quick_clean/screen/booking.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animate_do/animate_do.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key}); 
  @override 
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final supabase = Supabase.instance.client;
  Map<String, dynamic>? userData;
  List<ServiceModel> _services = [];
  List<ProviderModel> _providers = [];

  @override 
  void initState() { 
    super.initState(); 
    fetchUsers();
    _loadData();
  } 
  
  Future<void> fetchUsers() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return;
    }

    try {
      final data = await supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      setState(() {
        userData = data;
      });

      //print('Fetched users: $users');

    } catch (e) {
      //print('Error fetching users: $e');
    }
  }

  Future<void> _loadData() async {
    try {
      // Fetch both tables at once
      final serviceData = await supabase.from('services').select();
      final providerData = await supabase.from('service_providers').select();

      print("Fetched services: $serviceData");
      print("Fetched providers: $providerData");

      setState(() {
        _services = serviceData.map((s) => ServiceModel.fromMap(s)).toList();
        _providers = providerData.map((p) => ProviderModel.fromMap(p)).toList();
      });
    } catch (e) {
      print("Error loading data: $e");
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QuickClean', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: Icon(Icons.notifications), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FadeInUp(child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: EdgeInsets.all(10.0),
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      offset: Offset(0, 4),
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Image.network(
                            'https://images.pexels.com/photos/355164/pexels-photo-355164.jpeg?crop=faces&fit=crop&h=200&w=200&auto=compress&cs=tinysrgb', 
                            width: 70
                          )
                        ),
                        SizedBox(width: 15,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(userData?['name'] ?? '-', 
                              style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5,),
                            Text(userData?['email'] ?? '-', 
                              style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 18),
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 20,),
                    // Container(
                    //   height: 50,
                    //   decoration: BoxDecoration(
                    //     color: Colors.blue,
                    //     borderRadius: BorderRadius.circular(15.0)
                    //   ),
                    //   child: Center(child: Text('View Profile', style: TextStyle(color: Colors.white, fontSize: 18),)),
                    // )
                  ],
                ),
              ),
            )),
            SizedBox(height: 20,),
            FadeInUp(child: Padding(
              padding: EdgeInsets.only(left: 20.0, right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Bookings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  // TextButton(
                  //   onPressed: () {}, 
                  //   child: Text('View all',)
                  // )
                ],
              ),
            )),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: GridView.builder(
                shrinkWrap: true, // 👈 important
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: _services.length,
                itemBuilder: (BuildContext context, int index) {
                  return FadeInUp(
                    delay: Duration(milliseconds: 200 * index),
                    child: serviceContainer(
                      _services[index].imageUrl,
                      _services[index].name,
                      index,
                    ),
                  );
                },
              ),
            ),
            FadeInUp(child: Padding(
              padding: EdgeInsets.only(left: 20.0, right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Top Rated', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  // TextButton(
                  //   onPressed: () {}, 
                  //   child: Text('View all',)
                  // )
                ],
              ),
            )),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _providers.length,
                itemBuilder: (BuildContext context, int index) {
                  return FadeInUp(
                    delay: Duration(milliseconds: 500 * index),
                    child: workerContainer(_providers[index].name, _providers[index].specialty, _providers[index].imageUrl ?? '', _providers[index].rating));
                }
              ),
            ),
            SizedBox(height: 20,)
          ]
        )
      ),
      
      // Using BottomAppBar instead of BottomNavigationBar for custom layouts
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Container(
          height: 60.0,
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _contactIcon(Icons.phone, "Call", Colors.blue, 
                () => _launchURL('tel:+123456789')),
              
              _contactIcon(Icons.chat_bubble, "WhatsApp", Colors.green, 
                () => _launchURL('https://wa.me/123456789')),
              
              _contactIcon(Icons.email, "Email", Colors.redAccent, 
                () => _launchURL('mailto:info@clean.com')),

              // The Logout Button
              _contactIcon(Icons.logout, "Logout", Colors.black, 
                () => _showLogoutDialog(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget serviceContainer(String image, String name, int index) {
    return GestureDetector(
      onTap: () {
        // Navigate to the Booking Page and pass the service name
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingPage(serviceName: name),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border.all(
            color: Colors.blue.withOpacity(0),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(image, height: 45),
            const SizedBox(height: 20),
            Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  workerContainer(String name, String job, String image, double rating) {
    return GestureDetector(
      child: AspectRatio(
        aspectRatio: 3.5,
        child: Container(
          margin: EdgeInsets.only(right: 20),
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.grey.shade200,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.network(image)
              ),
              SizedBox(width: 20,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                  SizedBox(height: 5,),
                  Text(job, style: TextStyle(fontSize: 15),)
                ],
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(rating.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                  SizedBox(height: 5,),
                  Icon(Icons.star, color: Colors.orange, size: 20,)
                ],
              )
            ]
          ),
        ),
      ),
    );
  }

  Widget _contactIcon(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog( // renamed to innerContext for clarity
        title: const Text("Logout"),
        content: const Text("Are you sure you want to leave?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(innerContext), 
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              // Close the dialog first using its specific context
              Navigator.pop(innerContext);
              // Then call logout using the main page context
              _logout(context);
            }, 
            child: const Text("Logout", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}