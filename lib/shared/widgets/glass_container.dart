// shared/widgets/glass_container.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double blur;
  final double opacity;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;

  const GlassContainer({
    Key? key,
    required this.child,
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.all(20),
    this.margin = EdgeInsets.zero,
    this.blur = 15.0,
    this.opacity = 0.15,
    this.borderColor,
    this.borderWidth = 1.5,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
                padding: padding,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(opacity),
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(
                      color: borderColor ?? Colors.white.withOpacity(0.25),
                      width: borderWidth,
                    ),
                    boxShadow: boxShadow ??
                    [
                    BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: Offset(0, 10),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
            spreadRadius: 0,
          ),
          ],
      gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
          Colors.white.withOpacity(0.25),
      Colors.white.withOpacity(0.05),
      ],
    ),
    ),
    child: child,
    ),
    ),
    ),
    );
  }
}