import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'profile.dart';
import '/screens/turfowner/my_turfs.dart';
import '/screens/customer/explore_turfs.dart';
import '/util/colors.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  String appbarTitle = "Explore Turfs";
  String? type;

  Future<void> getType() async {
    final SharedPreferences preps = await SharedPreferences.getInstance();
    setState(() {
      type = preps.getString("type") ?? "guest";
    });
    print(type);
    setAppbarTitle();
  }

  void setAppbarTitle(){
    switch(_selectedIndex){
      case 0:
        appbarTitle = type=="turfowner" ? "My Turfs" : "Explore Turfs";
      case 1:
        appbarTitle = type=="turfowner" ? "Bookings" : "My Bookings";
      case 2:
        appbarTitle = "Profile";
    }
  }

  @override
  void initState() {
    super.initState();
    getType();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text(appbarTitle, style: TextStyle(fontSize: 20),),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // ==> FIRST TAB
          if(type == "guest" || type == "customer")
            ExploreTurfs(),
          if(type == "turfowner")
            MyTurfs(),
          // CircularProgressIndicator(),

          // ==> SECOND TAB
          Center(child: Text("Bookings Page")),

          // ==> THIRD TAB
          // Center(child: Text("Profile Page")),
          if(type == "guest")
            Center(child: Text("Profile Page")),
          if(type == "turfowner" || type == "customer")
            Profile(),
        ],
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: BMTTheme.brand.withOpacity(0.25),
              offset: Offset(0, -8),
              blurRadius: 40,
            )
          ],
        ),
        child: NavigationBar(
          backgroundColor: BMTTheme.black,
          elevation: 0,
          indicatorColor: BMTTheme.brand.withOpacity(0.4),
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState((){
              _selectedIndex = index;
              setAppbarTitle();
            });
          },
          destinations: [
            NavigationDestination(
              icon: Icon(CupertinoIcons.rectangle),
              label: "Turfs",
            ),
            NavigationDestination(
              icon: Icon(Icons.library_books),
              label: "Bookings",
            ),
            NavigationDestination(
              icon: Icon(CupertinoIcons.person_solid),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}

