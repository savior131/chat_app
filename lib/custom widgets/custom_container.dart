import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  const CustomContainer({
    super.key,
    required this.color,
    required this.child,
    this.height,
    this.width,
    this.radius = 0,
    this.border,
  });
  final Widget child;
  final Color color;
  final double? width;
  final double? height;
  final double radius;
  final Border? border;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: border,
        color: color,
      ),
      child: child,
    );
  }
}
