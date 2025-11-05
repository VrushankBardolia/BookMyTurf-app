import 'package:book_my_turf/util/colors.dart';
import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType type;
  final Icon? leading;
  final String? trailingText;
  final bool isPassword;
  final String? Function(String?)? validator;
  final Color? bgColor;
  final bool? editable;

  const Input({
    super.key,
    required this.controller,
    required this.hint,
    this.isPassword = false,
    this.leading,
    this.trailingText,
    required this.type,
    this.validator,
    this.bgColor,
    this.editable = true
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: controller,
      keyboardType: type,
      onTapOutside: (e)=>FocusScope.of(context).unfocus(),
      obscureText: isPassword,
      readOnly: !editable!,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16,),
        filled: true,
        fillColor: bgColor ?? BMTTheme.background,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: BMTTheme.brand),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        prefixIcon: leading,
        prefixIconColor: BMTTheme.white50,
        hintText: hint,
        hintStyle: TextStyle(color: BMTTheme.white50),
        suffixText: trailingText,
      ),
    );
  }
}
