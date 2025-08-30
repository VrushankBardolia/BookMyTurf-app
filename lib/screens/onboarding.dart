import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/components/buttons.dart';
import '/screens/auth/turfowner_login.dart';
import '/screens/auth/customer_login.dart';
import '/screens/home.dart';
import '/util/colors.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {

  Future<void> guest() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("type", "guest");
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Home()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          // BACKGROUND IMAGE
          Image.asset('assets/images/onboarding-bg.jpg',
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),

          // MAIN CONTENT
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    // TOP SECTION
                    Column(
                      children: [

                        Text("BookMyTurf",
                          style: TextStyle(
                            fontSize: 60,
                            fontFamily: 'Instrument Serif',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),

                    // BOTTOM SECTION
                    Column(
                      children: [
                        Text("Your One-Stop Destination for Turf Booking",
                          style: TextStyle(fontSize: 20, height: 1.2),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Button(
                          text: "Login",
                          onClick:()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>CustomerLogin())),
                        ),
                        SizedBox(height: 16),
                        Button(
                          text: "List my turf",
                          filled: false,
                          border: true,
                          backColor: BMTTheme.black50,
                          textColor: BMTTheme.white,
                          onClick: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>TurfownerLogin())),
                        ),
                        SizedBox(height: 8),
                        TextButton(
                          onPressed: guest,
                          child: Text("Continue as guest"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
