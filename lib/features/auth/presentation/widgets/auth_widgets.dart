import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final bool isPassword;
  final TextInputType keyboardType;
  final FocusNode? focusNode;
  final IconData? prefixIcon;
  final String? errorText;
  final Function(String)? onSubmitted;

  const AuthTextField({
    Key? key,
    required this.controller,
    required this.placeholder,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.focusNode,
    this.prefixIcon,
    this.errorText,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey6.withOpacity(0.8),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: CupertinoTextField(
            controller: controller,
            focusNode: focusNode,
            placeholder: placeholder,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: const BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            prefix: prefixIcon != null
                ? Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Icon(
                prefixIcon,
                color: CupertinoColors.activeBlue.withOpacity(0.7),
                size: 20,
              ),
            )
                : null,
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.label,
            ),
            placeholderStyle: TextStyle(
              fontSize: 16,
              color: CupertinoColors.placeholderText.withOpacity(0.6),
            ),
            suffix: isPassword
                ? Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                child: Icon(
                  CupertinoIcons.eye,
                  color: CupertinoColors.systemGrey.withOpacity(0.7),
                  size: 20,
                ),
                // TODO: Implement password visibility toggle
              ),
            )
                : null,
            obscureText: isPassword,
            keyboardType: keyboardType,
            autocorrect: !isPassword,
            enableSuggestions: !isPassword,
            textInputAction: TextInputAction.next,
            onSubmitted: onSubmitted,
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              errorText!,
              style: const TextStyle(
                color: CupertinoColors.destructiveRed,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}