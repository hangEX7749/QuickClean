// ignore_for_file: use_build_context_synchronously, deprecated_member_use, avoid_print
import 'package:flutter/material.dart';
import 'package:quick_clean/main.dart';
import 'package:quick_clean/models/service_models.dart';
import 'package:quick_clean/models/service_provider_model.dart';
import 'package:quick_clean/screen/booking.dart';
import 'package:quick_clean/screen/profile.dart';
import 'package:quick_clean/screen/view_booking.dart';
import 'package:quick_clean/state/user_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; 

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

      currentUserData.value = data;

      //print('Fetched users: $user');

    } catch (e) {
      //print('Error fetching users: $e');
    }
  }

  Future<void> _loadData() async {
    try {
      // Fetch both tables at once
      final serviceData = await supabase.from('services').select();
      final providerData = await supabase.from('service_providers').select();

      // print("Fetched services: $serviceData");
      // print("Fetched providers: $providerData");

      setState(() {
        _services = serviceData.map((s) => ServiceModel.fromMap(s)).toList();
        _providers = providerData.map((p) => ProviderModel.fromMap(p)).toList();
      });
    } catch (e) {
      print("Error loading data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QuickClean', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          PopupMenuButton<Locale>(
            // Use 'child' instead of 'icon' to combine Text and Icon
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Icon(Icons.language, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.changeLanguage, // Localize this!
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            onSelected: (Locale locale) {
              MyApp.setLocale(context, locale);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: Locale('en'),
                child: Text("English"),
              ),
              const PopupMenuItem(
                value: Locale('zh'),
                child: Text("中文"),
              ),
              const PopupMenuItem(
                value: Locale('ms'),
                child: Text("Bahasa Melayu"),
              ),
            ],
          ),
        ],
        
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
                            ValueListenableBuilder(
                              valueListenable: currentUserData,
                              builder: (context, userData, child) {
                                return FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text("Hello, ${userData?['username']}", style: TextStyle(fontSize: 20)),
                                );
                              },
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
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfilePage()),
                        );
                        fetchUsers();
                      },
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(15.0)
                        ),
                        child: Center(child: Text('View Profile', style: TextStyle(color: Colors.white, fontSize: 18),)),
                      ),
                    )
                  ],
                ),
              ),
            )),
            SizedBox(height: 20,),
            // Inside your home.dart build method, above your Services Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UserBookingsPage()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("My Bookings", 
                            style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 5),
                          Text("Check your service schedule", 
                            style: TextStyle(color: Colors.black, fontSize: 12)),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 18),
                    ],
                  ),
                ),
              ),
            ),
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
            LayoutBuilder(
              builder: (context, constraints) {
                // On very small screens, use 2 columns instead of 3
                int crossAxisCount = constraints.maxWidth < 350 ? 2 : 3;
                
                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    // Increase the ratio if the text is being cut off (height > width)
                    childAspectRatio: 0.85, 
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                  ),
                  itemCount: _services.length,
                  itemBuilder: (context, index) {
                    return serviceContainer(
                      _services[index].imageUrl,
                      _services[index].name,
                      index,
                    );
                  },
                );
              },
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
        ),
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
              _contactIcon(
                Icons.facebook, "Messenger", const Color(0xFF0084FF),
                () => _launchURL('https://m.me/YOUR_PAGE_ID_OR_USERNAME'),
              ),
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
            builder: (context) => BookingPage(serviceName: name, serviceId: _services[index].id),
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
    return Container(
      margin: EdgeInsets.only(right: 20),
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      // Remove AspectRatio, use width based on screen size
      width: MediaQuery.of(context).size.width * 0.8, 
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200, width: 2.0),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Image.network(image, width: 50, height: 50, fit: BoxFit.cover),
          ),
          SizedBox(width: 15),
          // Use Expanded so the text knows it must stay within the remaining space
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name, 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis, // Adds "..." if name is too long
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(job, style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
          // Rating section
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(rating.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
              Icon(Icons.star, color: Colors.orange, size: 18),
            ],
          )
        ],
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

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}