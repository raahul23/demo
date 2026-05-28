import 'package:flutter/material.dart';

ThemeData _testTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    useMaterial3: false,
    splashFactory: InkRipple.splashFactory,
  );
}

class TestApp extends StatelessWidget {
  final Widget home;
  final ThemeData? theme;
  final List<NavigatorObserver> navigatorObservers;

  const TestApp({
    super.key,
    required this.home,
    this.theme,
    this.navigatorObservers = const [],
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme ?? _testTheme(),
      home: home,
      navigatorObservers: navigatorObservers,
    );
  }
}
