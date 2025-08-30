import 'package:book_my_turf/screens/home.dart';
import 'package:book_my_turf/screens/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstScreenNavigator extends StatefulWidget {
  const FirstScreenNavigator({super.key});

  @override
  State<FirstScreenNavigator> createState() => _FirstScreenNavigatorState();
}

class _FirstScreenNavigatorState extends State<FirstScreenNavigator> {

  String? userType;

  @override
  void initState() {
    super.initState();
    getUserType();
  }

  Future<void> getUserType() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userType = prefs.getString("type") ?? "guest";
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userType == null) {
      return const CircularProgressIndicator();
    }
    print("FirstScreenNavigator => $userType");
    if (userType == "turfowner" || userType == "customer") {
      return const Home();
    } else {
      return const Onboarding();
    }
  }
}
