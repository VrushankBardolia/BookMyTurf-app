import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/blurred_circle.dart';
import '../../screens/auth/turfowner_signup.dart';
import '../../components/buttons.dart';
import '../../components/input.dart';
import '../../util/colors.dart';
import '../../util/api.dart';
import '../home.dart';

class TurfownerLogin extends StatefulWidget {
  const TurfownerLogin({super.key});

  @override
  State<TurfownerLogin> createState() => _TurfownerLoginState();
}

class _TurfownerLoginState extends State<TurfownerLogin> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> handleLogin() async {
    final response = await turfownerLogin(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    print(response);

    if (response['status'] == 'success') {
      final user = response['data'];

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("type", "turfowner");
      await prefs.setInt("id", user["id"]);
      await prefs.setString("name", user["name"]);
      await prefs.setString("email", user["email"]);
      await prefs.setString("phone", user["phone"]);
      print(prefs.getInt("id"));

      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Home()), (route) => false,);

    } else {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Login Failed'),
          content: Text(response['message']),
          actions: [
            TextButton(onPressed: ()=>Navigator.pop(context), child: Text("Okay"))
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BMTTheme.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        children: [

          // TOP BLURRED CIRCLE
          BlurredCircle(),

          // MAIN CONTENT
          SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.fromLTRB(16, 90, 16, 16),
              padding: EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: BMTTheme.black,
                borderRadius: BorderRadiusGeometry.all(Radius.circular(24)),
                border: Border.all(color: BMTTheme.white.withOpacity(0.2)),
              ),
              child: Column(
                // spacing: 24,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/icons/login.png',
                    height: 200,
                  ),
                  Text("Welcome back Turfowner",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 20),
                  Input(
                    controller: emailController,
                    hint: "Enter e-mail",
                    type: TextInputType.emailAddress,
                    leading: Icon(Icons.email_outlined),
                  ),
                  SizedBox(height: 20),
                  Input(
                    controller: passwordController,
                    hint: "Enter password",
                    type: TextInputType.visiblePassword,
                    leading: Icon(Icons.key_rounded),
                    isPassword: true,
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("New to Book My Turf?"),
                      TextButton(
                        onPressed: ()=> Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>TurfownerSignup())),
                        child: Text("Create Account"),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Button(text: "Login", onClick: handleLogin)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
