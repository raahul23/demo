import 'dart:io';

import 'package:flutter/services.dart';

abstract class BookingOverlayService {
  Future<bool> ensurePermission();
  Future<bool> hasPermission();
  Future<void> show();
  Future<void> hide();
  Future<bool> isActive();
}

class BookingOverlayServiceImpl implements BookingOverlayService {
  static const MethodChannel _channel = MethodChannel('booking_overlay');
  bool _requestInFlight = false;

  @override
  Future<bool> ensurePermission() async {
    if (!Platform.isAndroid) return false;
    try {
      if (_requestInFlight) return false;
      _requestInFlight = true;
      final granted =
          await _channel.invokeMethod<bool>('checkPermission') ?? false;
      if (granted) return true;
      await _channel.invokeMethod('requestPermission');
      final after =
          await _channel.invokeMethod<bool>('checkPermission') ?? false;
      return after;
    } catch (_) {
      return false;
    } finally {
      _requestInFlight = false;
    }
  }

  @override
  Future<bool> hasPermission() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('checkPermission') ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> show() async {
    if (!Platform.isAndroid) return;
    try {
      final active =
          await _channel.invokeMethod<bool>('isActive') ?? false;
      if (active) return;
      await _channel.invokeMethod('showOverlay');
    } catch (_) {}
  }

  @override
  Future<void> hide() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('hideOverlay');
    } catch (_) {}
  }

  @override
  Future<bool> isActive() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('isActive') ?? false;
    } catch (_) {
      return false;
    }
  }
}
