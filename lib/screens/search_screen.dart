import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';
import '../widgets/search_card.dart';
import '../widgets/popular_route_item.dart';
import '../services/user_service.dart';
import 'trips_screen.dart';
import 'my_trips_screen.dart';
import 'wallet_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';
import 'log_in_screen.dart';
import 'admin_panel_screen.dart';
import 'supervisor_trips_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String? fromCity;
  String? toCity;
  String seatType = 'normal';
  DateTime selectedDate = DateTime.now();
  String? userRole;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  void _fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final role = await UserService().getUserRole(user.uid);
      if (mounted) setState(() => userRole = role);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          "app_title".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, color: kWhiteColor),
        ),
        backgroundColor: kPrimaryColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: kWhiteColor),
        actions: [
          if (FirebaseAuth.instance.currentUser != null)
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                );
              },
              icon: const Icon(Icons.notifications_none_rounded),
            ),
        ],
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              decoration: const BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "welcome_msg".tr(),
                    style: const TextStyle(color: kWhiteColor, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "where_to".tr(),
                    style: TextStyle(color: kWhiteColor.withOpacity(0.8), fontSize: 16),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Form
                  Stack(
                    children: [
                      Column(
                        children: [
                          SearchCard(
                            title: "departure_station".tr(),
                            icon: Icons.location_on_outlined,
                            child: DropdownButtonFormField<String>(
                              value: fromCity,
                              hint: Text("select_departure_city".tr()),
                              isExpanded: true,
                              items: kSyrianCities
                                  .map((city) => DropdownMenuItem(
                                        value: city,
                                        child: Text(city.tr()),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  fromCity = val;
                                  if (toCity == fromCity) toCity = null;
                                });
                              },
                              decoration: const InputDecoration(border: InputBorder.none),
                            ),
                          ),
                          const SizedBox(height: 15),
                          SearchCard(
                            title: "arrival_destination".tr(),
                            icon: Icons.location_on,
                            child: DropdownButtonFormField<String>(
                              value: toCity,
                              hint: Text("select_arrival_city".tr()),
                              isExpanded: true,
                              items: kSyrianCities
                                  .where((city) => city != fromCity)
                                  .map((city) => DropdownMenuItem(
                                        value: city,
                                        child: Text(city.tr()),
                                      ))
                                  .toList(),
                              onChanged: (val) => setState(() => toCity = val),
                              decoration: const InputDecoration(border: InputBorder.none),
                            ),
                          ),
                        ],
                      ),
                      // Swap Button in between
                      Positioned(
                        top: 60,
                        left: context.locale.languageCode == 'ar' ? 20 : null,
                        right: context.locale.languageCode == 'en' ? 20 : null,
                        child: GestureDetector(
                          onTap: () {
                            if (fromCity != null || toCity != null) {
                              setState(() {
                                String? temp = fromCity;
                                fromCity = toCity;
                                toCity = temp;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: kWhiteColor,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                            ),
                            child: const Icon(Icons.swap_vert, color: kPrimaryColor),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: SearchCard(
                          title: "date".tr(),
                          icon: Icons.calendar_today_rounded,
                          child: InkWell(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 90)),
                              );
                              if (picked != null) setState(() => selectedDate = picked);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                "${selectedDate.year}/${selectedDate.month}/${selectedDate.day}",
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: SearchCard(
                          title: "class".tr(),
                          icon: Icons.airline_seat_recline_extra,
                          child: DropdownButtonFormField<String>(
                            value: seatType,
                            isExpanded: true,
                            items: [
                              DropdownMenuItem(value: 'normal', child: Text("normal".tr(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                              DropdownMenuItem(value: 'VIP', child: Text("vip".tr(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                            ],
                            onChanged: (val) => setState(() => seatType = val!),
                            decoration: const InputDecoration(border: InputBorder.none),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Search Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 3,
                      ),
                      onPressed: () {
                        if (fromCity != null && toCity != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TripsScreen(
                                fromCity: fromCity!,
                                toCity: toCity!,
                                date: selectedDate,
                                seatType: seatType,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("error_select_cities".tr()),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                      child: Text(
                        "search_button".tr(),
                        style: const TextStyle(fontSize: 18, color: kWhiteColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "popular_routes".tr(),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kSecondaryColor),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text("view_all".tr(), style: const TextStyle(color: kPrimaryColor)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  PopularRouteItem(
                    from: "aleppo",
                    to: "damascus",
                    price: "45,000 ${"currency".tr()}",
                    onTap: () => _quickSearch("aleppo", "damascus"),
                  ),
                  PopularRouteItem(
                    from: "homs",
                    to: "latakia",
                    price: "25,000 ${"currency".tr()}",
                    onTap: () => _quickSearch("homs", "latakia"),
                  ),
                  PopularRouteItem(
                    from: "damascus",
                    to: "tartous",
                    price: "35,000 ${"currency".tr()}",
                    onTap: () => _quickSearch("damascus", "tartous"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _quickSearch(String from, String to) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripsScreen(
          fromCity: from,
          toCity: to,
          date: DateTime.now(),
          seatType: 'normal',
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    final User? user = FirebaseAuth.instance.currentUser;
    final bool isLoggedIn = user != null;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: kPrimaryColor,
              image: DecorationImage(
                image: AssetImage("assets/images/bus.jpg"),
                fit: BoxFit.cover,
                opacity: 0.3,
              ),
            ),
            currentAccountPicture: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kWhiteColor, width: 2),
              ),
              child: const CircleAvatar(
                backgroundColor: kWhiteColor,
                child: Icon(Icons.person, size: 45, color: kPrimaryColor),
              ),
            ),
            accountName: Text(
                isLoggedIn ? (user.displayName ?? "smart_traveller".tr()) : "welcome_msg".tr(),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: Text(isLoggedIn ? (user.email ?? "") : ""),
          ),
          _buildDrawerItem(Icons.search, "search_trips".tr(), () => Navigator.pop(context)),
          if (isLoggedIn) ...[
            _buildDrawerItem(Icons.airplane_ticket_outlined, "my_bookings".tr(), () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyTripsScreen()));
            }),
            _buildDrawerItem(Icons.account_balance_wallet_outlined, "wallet".tr(), () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const WalletScreen()));
            }),
            _buildDrawerItem(Icons.notifications_none_rounded, "notifications".tr(), () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
            }),
            if (userRole == 'admin')
              _buildDrawerItem(Icons.admin_panel_settings_outlined, "admin_panel".tr(), () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminPanelScreen()));
              }, color: Colors.orangeAccent),
            if (userRole == 'supervisor')
              _buildDrawerItem(Icons.assignment_ind_outlined, "assigned_trips".tr(), () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SupervisorTripsScreen()));
              }, color: Colors.blueAccent),
          ],
          const Divider(height: 30),
          _buildDrawerItem(Icons.settings_outlined, "settings".tr(), () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
          }),
          _buildDrawerItem(Icons.info_outline, "about_app".tr(), () {
            Navigator.pop(context);
            _showAboutDialog(context);
          }),
          const Spacer(),
          if (isLoggedIn)
            _buildDrawerItem(Icons.logout_rounded, "logout".tr(), () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
              }
            }, color: Colors.redAccent)
          else
            _buildDrawerItem(Icons.login_rounded, "login".tr(), () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LogInScreen())).then((_) {
                setState(() {});
              });
            }, color: kPrimaryColor),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("about_app".tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor)),
        content: Text("about_content".tr() + "\n\n" + "app_version".tr()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("close".tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? kPrimaryColor),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: color ?? kSecondaryColor,
        ),
      ),
      onTap: onTap,
    );
  }
}
