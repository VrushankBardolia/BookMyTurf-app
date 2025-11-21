import 'package:book_my_turf/screens/customer/search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/screens/customer/explore_turfs.dart';
import '/screens/customer/my_bookings.dart';
import '/screens/turfowner/my_turfs.dart';
import '/screens/turfowner/turf_bookings.dart';
import 'settings.dart';
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
    debugPrint(type);
    setAppbarTitle();
  }

  void setAppbarTitle(){
    switch(_selectedIndex){
      case 0:
        appbarTitle = type=="turfowner" ? "My Turfs" : "Explore Turfs";
      case 1:
        appbarTitle = type=="turfowner" ? "Bookings" : "My Bookings";
      case 2:
        appbarTitle = "Settings";
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
        title: Text(appbarTitle),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if(_selectedIndex == 0 && type != "turfowner")
            IconButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Search()));
              },
              icon: Icon(CupertinoIcons.search),
            ),
        ],
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
          if(type == "customer")
            MyBookings(),
          if(type == "turfowner")
            TurfBookings(),
          if(type == "guest")
            Center(child: Text("Guest Page")),

          // ==> THIRD TAB
          if(type == "guest")
            Center(child: Text("Profile Page")),
          if(type == "turfowner" || type == "customer")
            Settings(),
        ],
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: BMTTheme.brand.withValues(alpha: 0.25),
              offset: Offset(0, -4),
              blurRadius: 40,
            )
          ],
        ),
        child: NavigationBar(
          backgroundColor: BMTTheme.black,
          elevation: 0,
          indicatorColor: BMTTheme.brand.withValues(alpha: 0.4),
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
              icon: Icon(Icons.receipt),
              label: "Bookings",
            ),
            NavigationDestination(
              icon: Icon(CupertinoIcons.gear),
              label: "Settings",
            ),
          ],
        ),
      ),
    );
  }
}

