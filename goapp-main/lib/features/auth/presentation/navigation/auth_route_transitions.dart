import 'package:flutter/material.dart';

import '../theme/auth_font_scope.dart';
import '../widgets/login_form.dart';

Route<T> onboardingSlideRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) =>
        AuthFontScope(child: page),
    transitionDuration: const Duration(milliseconds: 700),
    reverseTransitionDuration: const Duration(milliseconds: 560),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final moveCurve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuart,
        reverseCurve: Curves.easeInQuart,
      );
      final fadeCurve = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.82, curve: Curves.easeOutCubic),
        reverseCurve: const Interval(0.0, 1.0, curve: Curves.easeInCubic),
      );
      return FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(fadeCurve),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.06, 0),
            end: Offset.zero,
          ).animate(moveCurve),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.985, end: 1.0).animate(moveCurve),
            child: child,
          ),
        ),
      );
    },
  );
}

Route<void> loginFormRoute() {
  return MaterialPageRoute(
    builder: (_) => const AuthFontScope(child: _LoginFormPage()),
  );
}

class _LoginFormPage extends StatelessWidget {
  const _LoginFormPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: LoginForm());
  }
}
