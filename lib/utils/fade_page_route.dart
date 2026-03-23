// lib/utils/fade_page_route.dart (New File)

import 'package:flutter/material.dart';

// This custom route provides a smooth fade transition between pages
class FadePageRoute extends PageRouteBuilder {
  final Widget child;

  FadePageRoute({required this.child})
      : super(
          transitionDuration: const Duration(milliseconds: 700), // Longer, smoother fade
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}