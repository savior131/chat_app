import 'package:chat_app/widgets/theme.dart';
import 'package:flutter/material.dart';

customSnackBar(String message, BuildContext context,
    [String? buttonText, VoidCallback? onTab]) {
  ScaffoldMessenger.of(context).clearSnackBars();

  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      width: MediaQuery.of(context).size.width * 0.85,
      content: Text(
        textAlign: TextAlign.center,
        message,
        style: const TextStyle(
          color: Colors.white70,
        ),
      ),
      backgroundColor: colorScheme.surface,
      action: (buttonText == null || onTab == null)
          ? null
          : SnackBarAction(
              label: buttonText,
              onPressed: onTab,
              textColor: colorScheme.onSurface,
            ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
