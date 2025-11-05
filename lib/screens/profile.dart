import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/components/buttons.dart';
import '/screens/onboarding.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // print(prefs.getString("type"));
    prefs.remove("type");
    // print(prefs.getString("type"));

    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Onboarding()), (route) => false,);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(
            child: Button(text: "Logout", onClick:logout),
          ),
        ],
      ),
    );
  }
}
