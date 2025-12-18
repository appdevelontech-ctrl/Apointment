import 'package:flutter/material.dart';

class SmoothNavigator {
  static Future<T?> push<T>(
      BuildContext context,
      Widget page, {
        Duration duration = const Duration(milliseconds: 420),
      }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: duration,
        reverseTransitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final slide = Tween<Offset>(
            begin: const Offset(1.0, 0.0), // right → left
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          );

          final fade = Tween<double>(
            begin: 0,
            end: 1,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
          );

          return SlideTransition(
            position: slide,
            child: FadeTransition(
              opacity: fade,
              child: child,
            ),
          );
        },
      ),
    );
  }
}
