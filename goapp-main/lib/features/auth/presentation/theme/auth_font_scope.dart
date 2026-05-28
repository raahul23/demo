import 'package:flutter/material.dart';
import '../../../../core/utils/constants.dart';

class AuthFontScope extends StatelessWidget {
  const AuthFontScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final sairaTextTheme = base.textTheme.apply(fontFamily: AppFonts.saira);

    return Theme(
      data: base.copyWith(
        textTheme: sairaTextTheme,
        primaryTextTheme: base.primaryTextTheme.apply(
          fontFamily: AppFonts.saira,
        ),
      ),
      child: child,
    );
  }
}
