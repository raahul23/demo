import 'package:flutter/material.dart';

class ServiceIconMapper {
  static IconData fromKey(String iconKey) {
    switch (iconKey) {
      case 'bike':
        return Icons.two_wheeler;
      case 'auto':
        return Icons.local_taxi;
      case 'car':
        return Icons.directions_car;
      case 'scooty':
        return Icons.moped;
      case 'women':
        return Icons.woman;
      case 'premium':
        return Icons.star;
      case 'parcel':
        return Icons.local_shipping;
      default:
        return Icons.circle;
    }
  }
}
