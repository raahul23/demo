import 'dart:io';

import 'package:flutter/services.dart';

abstract class BookingForegroundService {
  Future<void> init();
  Future<void> start();
  Future<void> stop();
  Future<bool> isRunning();
}

class BookingForegroundServiceImpl implements BookingForegroundService {
  static const MethodChannel _channel = MethodChannel('booking_foreground');

  @override
  Future<void> init() async {
    if (!Platform.isAndroid) return;
  }

  @override
  Future<void> start() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod('start');
  }

  @override
  Future<void> stop() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod('stop');
  }

  @override
  Future<bool> isRunning() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('isRunning') ?? false;
    } catch (_) {
      return false;
    }
  }
}
