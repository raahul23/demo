import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:fake_async/fake_async.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:goapp/core/maps/vehicle_marker_controller.dart';

void main() {
  test('controller pauses when app goes to background', () {
    fakeAsync((async) {
      int updates = 0;
      final controller = VehicleMarkerController(
        onUpdate: () => updates++,
        animate: true,
        tick: const Duration(milliseconds: 100),
      );

      controller.start(const LatLng(12.0, 77.0));
      async.elapse(const Duration(milliseconds: 350));
      final beforePause = updates;
      expect(beforePause, greaterThan(0));

      controller.handleLifecycle(AppLifecycleState.paused);
      async.elapse(const Duration(milliseconds: 300));
      expect(updates, beforePause);

      controller.handleLifecycle(AppLifecycleState.resumed);
      async.elapse(const Duration(milliseconds: 300));
      expect(updates, greaterThan(beforePause));
    });
  });

  test('controller uses smoother tick interval', () {
    fakeAsync((async) {
      int updates = 0;
      final controller = VehicleMarkerController(
        onUpdate: () => updates++,
        animate: true,
        tick: const Duration(milliseconds: 200),
      );

      controller.start(const LatLng(12.0, 77.0));
      async.elapse(const Duration(milliseconds: 650));
      expect(updates, inInclusiveRange(3, 4));
    });
  });
}
