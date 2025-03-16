import 'package:chat_app/widgets/theme.dart';
import 'package:flutter/material.dart';

class StrokeText extends StatelessWidget {
  const StrokeText(
    this.text, {
    super.key,
    required this.style,
    required this.strokeSize,
    this.textAlign,
    this.strokeColor = Colors.white,
  });
  final String text;
  final TextAlign? textAlign;
  final TextStyle style;
  final double strokeSize;
  final Color strokeColor;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(shadows: [
        Shadow(
          color: colorScheme.surface,
          offset: Offset(0, strokeSize),
        ),
        Shadow(
          color: colorScheme.surface,
          offset: Offset(strokeSize, 0),
        ),
        Shadow(
          color: colorScheme.surface,
          offset: Offset(-strokeSize, 0),
        ),
        Shadow(
          color: colorScheme.surface,
          offset: Offset(0, -strokeSize),
        )
      ]),
      textAlign: textAlign,
    );
  }
}
