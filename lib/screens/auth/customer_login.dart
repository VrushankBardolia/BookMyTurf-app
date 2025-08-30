import 'package:book_my_turf/components/blurred_circle.dart';
import 'package:book_my_turf/screens/auth/customer_signup.dart';
import 'package:book_my_turf/util/api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/buttons.dart';
import '../../components/input.dart';
import '../../util/colors.dart';
import '../home.dart';

class CustomerLogin extends StatefulWidget {
  const CustomerLogin({super.key});

  @override
  State<CustomerLogin> createState() => _CustomerLoginState();
}

class _CustomerLoginState extends State<CustomerLogin> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> handleLogin() async {
    final response = await customerLogin(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (response['status'] == 'success') {
      final user = response['data'];
      print('Welcome ${user['fullname']}');

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("type", "customer");
      await prefs.setString("name", user["fullname"]);
      await prefs.setString("email", user["email"]);
      await prefs.setString("phone", user["phone"]);

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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/icons/login.png', height: 200,),

                  Text("Welcome back",
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
                        onPressed: ()=> Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>CustomerSignup())),
                        child: Text("Create Account"),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  Button(text: "Login", onClick: handleLogin,)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
