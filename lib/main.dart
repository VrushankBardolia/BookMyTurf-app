import 'package:flutter/material.dart';

import '/util/colors.dart';
import '/util/first_screen_navigator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book My Turf',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        fontFamily: 'Parkinsans'
      ),
      home: const FirstScreenNavigator(),
    );
  }
}
