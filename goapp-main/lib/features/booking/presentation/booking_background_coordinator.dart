import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:goapp/features/booking/domain/entities/driver_search_status.dart';
import 'package:goapp/features/booking/presentation/cubit/booking_state.dart';

import '../../../core/services/booking_foreground_service.dart';
import '../../../core/services/booking_overlay_service.dart';


class BookingBackgroundCoordinator {
  final BookingForegroundService foregroundService;
  final BookingOverlayService overlayService;
  bool _bookingActive = false;
  bool _appInForeground = true;
  bool _pendingOverlayPermission = false;

  BookingBackgroundCoordinator({
    required this.foregroundService,
    required this.overlayService,
  });

  Future<void> handleBookingState(BookingState state) async {
    final isActive = _isBookingActive(state.driverSearchStatus);
    if (isActive && !_bookingActive) {
      _bookingActive = true;
      await foregroundService.start();
      if (_appInForeground) {
        final granted = await overlayService.ensurePermission();
        if (!granted) {
          _pendingOverlayPermission = true;
        }
      } else {
        _pendingOverlayPermission = true;
      }
      if (!_appInForeground) {
        final granted = await overlayService.hasPermission();
        if (granted) {
          await overlayService.show();
        }
      }
      return;
    }
    if (!isActive && _bookingActive) {
      _bookingActive = false;
      _pendingOverlayPermission = false;
      await overlayService.hide();
      await foregroundService.stop();
    }
  }

  Future<void> handleLifecycle(AppLifecycleState state) async {
    if (state == AppLifecycleState.detached) {
      _appInForeground = false;
      return;
    }
    final nowForeground = state == AppLifecycleState.resumed;
    _appInForeground = nowForeground;
    if (!_bookingActive) return;
    if (nowForeground) {
      await overlayService.hide();
      if (_pendingOverlayPermission) {
        final granted = await overlayService.ensurePermission();
        if (granted) {
          _pendingOverlayPermission = false;
        }
      }
    } else {
      final granted = await overlayService.ensurePermission();
      if (granted) {
        await overlayService.show();
      } else {
        _pendingOverlayPermission = true;
      }
    }
  }

  bool _isBookingActive(DriverSearchStatus status) {
    return status != DriverSearchStatus.idle &&
        status != DriverSearchStatus.completed;
  }

}
