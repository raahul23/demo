import "package:flutter/material.dart";

class Responsive {
  Responsive._();

  static double scale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final ratio = width / 375;
    return ratio.clamp(0.85, 1.25);
  }

  static double size(BuildContext context, double value) {
    return value * scale(context);
  }

  static double font(BuildContext context, double value) {
    return value * scale(context);
  }

  static EdgeInsets insetsAll(BuildContext context, double value) {
    final scaled = size(context, value);
    return EdgeInsets.all(scaled);
  }

  static EdgeInsets insetsSymmetric(
      BuildContext context, {
        double horizontal = 0,
        double vertical = 0,
      }) {
    return EdgeInsets.symmetric(
      horizontal: size(context, horizontal),
      vertical: size(context, vertical),
    );
  }

  static EdgeInsets insetsLTRB(
      BuildContext context, {
        double left = 0,
        double top = 0,
        double right = 0,
        double bottom = 0,
      }) {
    return EdgeInsets.fromLTRB(
      size(context, left),
      size(context, top),
      size(context, right),
      size(context, bottom),
    );
  }
}
