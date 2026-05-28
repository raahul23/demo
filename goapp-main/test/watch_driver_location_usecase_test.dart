import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:goapp/features/booking/domain/entities/geo_point.dart';
import 'package:goapp/features/booking/domain/repositories/driver_tracking_repository.dart';
import 'package:goapp/features/booking/domain/usecases/watch_driver_location_usecase.dart';

class FakeDriverTrackingRepository implements DriverTrackingRepository {
  FakeDriverTrackingRepository(this.controller);

  final StreamController<GeoPoint> controller;
  String? lastRideId;
  bool disconnected = false;

  @override
  Stream<GeoPoint> trackDriver({required String rideId}) {
    lastRideId = rideId;
    return controller.stream;
  }

  @override
  Future<void> disconnect() async {
    disconnected = true;
    controller.close();
  }
}

void main() {
  test('WatchDriverLocationUseCase returns repository stream', () async {
    final controller = StreamController<GeoPoint>();
    final repository = FakeDriverTrackingRepository(controller);
    final useCase = WatchDriverLocationUseCase(repository);
    const sample = GeoPoint(lat: 11.0, lng: 22.0);

    final stream = useCase(rideId: 'ride-123');
    final expectation = expectLater(
      stream,
      emitsInOrder([sample, emitsDone]),
    );

    controller.add(sample);
    await controller.close();

    await expectation;
    expect(repository.lastRideId, 'ride-123');
  });

  test('disconnect forwards to repository', () async {
    final controller = StreamController<GeoPoint>();
    final repository = FakeDriverTrackingRepository(controller);
    final useCase = WatchDriverLocationUseCase(repository);

    await useCase.disconnect();

    expect(repository.disconnected, true);
  });
}
