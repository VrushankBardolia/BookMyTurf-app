import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/blurred_circle.dart';
import '../../screens/auth/customer_login.dart';
import '../../components/buttons.dart';
import '../../components/input.dart';
import '../../util/api.dart';
import '../../util/colors.dart';
import '../home.dart';

class TurfownerSignup extends StatefulWidget {
  const TurfownerSignup({super.key});

  @override
  State<TurfownerSignup> createState() => _TurfownerSignupState();
}

class _TurfownerSignupState extends State<TurfownerSignup> {

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final numberController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> handleSignup() async {
    final response = await turfownerSignup(
      fullNameController.text.trim(),
      emailController.text.trim(),
      numberController.text.trim(),
      passwordController.text.trim(),
    );

    if (response['status'] == 'success') {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt("id", response["id"]);
      await prefs.setString("type", "turfowner");
      await prefs.setString("name", fullNameController.text.trim());
      await prefs.setString("email", emailController.text.trim());
      await prefs.setString("phone", numberController.text.trim());

      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Home()), (route) => false,);
    } else {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Signup Failed'),
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
                border: Border.all(color: BMTTheme.white.withValues(alpha: 0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/icons/signup.png',
                    height: 200,
                  ),
                  Text("Welcome Turfowner",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800,),
                  ),
                  SizedBox(height: 20),

                  Input(
                    controller: fullNameController,
                    hint: "Enter full name",
                    type: TextInputType.name,
                    leading: Icon(Icons.person),
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
                    controller: numberController,
                    hint: "Enter phone number",
                    type: TextInputType.phone,
                    leading: Icon(Icons.phone),
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
                      Text("Familiar to Book My Turf?"),
                      TextButton(
                        onPressed: ()=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>CustomerLogin())),
                        child: Text("Login"),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Button(text: "Create Account", onClick: handleSignup)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
