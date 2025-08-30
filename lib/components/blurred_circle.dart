import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../util/colors.dart';

class BlurredCircle extends StatelessWidget {
  const BlurredCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      heightFactor: 0,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(
          height: 240,
          width: 240,
          decoration: BoxDecoration(
            color: BMTTheme.brand.withOpacity(0.25),
            borderRadius: BorderRadius.circular(500),
          ),
        ),
      ),
    );
  }
}
