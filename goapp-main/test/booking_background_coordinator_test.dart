import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/features/booking/presentation/booking_background_coordinator.dart';
import 'package:goapp/features/booking/presentation/cubit/booking_state.dart';
import 'package:goapp/features/booking/domain/entities/driver_search_status.dart';
import 'package:goapp/features/booking/domain/entities/geo_point.dart';
import 'package:goapp/core/services/booking_foreground_service.dart';
import 'package:goapp/core/services/booking_overlay_service.dart';

class _FakeForegroundService implements BookingForegroundService {
  int startCount = 0;
  int stopCount = 0;
  bool running = false;

  @override
  Future<void> init() async {}

  @override
  Future<void> start() async {
    startCount += 1;
    running = true;
  }

  @override
  Future<void> stop() async {
    stopCount += 1;
    running = false;
  }

  @override
  Future<bool> isRunning() async => running;
}

class _FakeOverlayService implements BookingOverlayService {
  int showCount = 0;
  int hideCount = 0;
  int ensureCount = 0;
  int permissionCount = 0;
  bool active = false;
  bool permissionGranted = true;

  @override
  Future<bool> ensurePermission() async {
    ensureCount += 1;
    return permissionGranted;
  }

  @override
  Future<bool> hasPermission() async {
    permissionCount += 1;
    return permissionGranted;
  }

  @override
  Future<void> show() async {
    showCount += 1;
    active = true;
  }

  @override
  Future<void> hide() async {
    hideCount += 1;
    active = false;
  }

  @override
  Future<bool> isActive() async => active;
}

BookingState _baseState({required DriverSearchStatus status}) {
  return BookingState.initial(
    pickup: const GeoPoint(lat: 1, lng: 2),
    drop: const GeoPoint(lat: 3, lng: 4),
    pickupLabel: 'Pickup',
    dropLabel: 'Drop',
  ).copyWith(driverSearchStatus: status);
}

void main() {
  test('shows overlay in background and hides on completion', () async {
    final foreground = _FakeForegroundService();
    final overlay = _FakeOverlayService();
    final coordinator = BookingBackgroundCoordinator(
      foregroundService: foreground,
      overlayService: overlay,
    );

    await coordinator.handleBookingState(
      _baseState(status: DriverSearchStatus.searching),
    );
    expect(foreground.startCount, 1);
    expect(overlay.showCount, 0);
    expect(overlay.ensureCount, 1);

    await coordinator.handleLifecycle(AppLifecycleState.paused);
    expect(overlay.showCount, 1);
    expect(overlay.active, true);
    expect(overlay.permissionCount, 0);
    expect(overlay.ensureCount, 2);

    await coordinator.handleBookingState(
      _baseState(status: DriverSearchStatus.completed),
    );
    expect(overlay.hideCount, 1);
    expect(overlay.active, false);
  });
}
