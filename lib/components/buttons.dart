import 'package:book_my_turf/util/colors.dart';
import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;
  final bool filled;
  final bool border;
  final Color backColor;
  final Color textColor;
  final Color borderColor;
  final Function() onClick;

  const Button({
    super.key,
    required this.text,
    this.filled = true,
    this.border = false,
    this.backColor = BMTTheme.brand,
    this.textColor = BMTTheme.black,
    this.borderColor = BMTTheme.brand,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: filled ? backColor : Colors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(12)),
          border: border
              ? Border.all(color: borderColor)
              : null,
        ),
        child: Center(
          child: Text(text,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
