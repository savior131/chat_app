import 'package:chat_app/widgets/theme.dart';
import 'package:flutter/material.dart';

InputDecoration custumInputFieldDecoration(String hintText,
        {IconData? icon, Widget? suffixIcon}) =>
    InputDecoration(
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: colorScheme.tertiary,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: colorScheme.tertiary,
        ),
      ),
      errorStyle: TextStyle(
        color: colorScheme.tertiary,
      ),
      prefixIcon: Icon(icon),
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Colors.white38,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      suffixIcon: suffixIcon,
    );
