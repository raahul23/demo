import 'package:flutter/services.dart';

class MapStyle {
  static const _stylePath = 'assets/maps/map_style.json';
  static const _bookingStylePath = 'assets/maps/booking_map_style.json';
  static String? _cached;
  static String? _bookingCached;

  static Future<String> load() async {
    if (_cached != null) return _cached!;
    _cached = await rootBundle.loadString(_stylePath);
    return _cached!;
  }

  static Future<String> loadBooking() async {
    if (_bookingCached != null) return _bookingCached!;
    _bookingCached = await rootBundle.loadString(_bookingStylePath);
    return _bookingCached!;
  }
}
