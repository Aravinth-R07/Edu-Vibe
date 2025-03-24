import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final bool isPassword;
  final TextInputType keyboardType;

  const AuthTextField({
    Key? key,
    required this.controller,
    required this.placeholder,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        border: Border.all(color: CupertinoColors.systemGrey4),
        borderRadius: BorderRadius.circular(8),
      ),
      obscureText: isPassword,
      keyboardType: keyboardType,
      autocorrect: !isPassword,
    );
  }
}