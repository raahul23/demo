import 'package:flutter_test/flutter_test.dart';

import 'package:goapp/features/booking/domain/entities/booking_route.dart';
import 'package:goapp/features/booking/domain/entities/geo_point.dart';
import 'package:goapp/features/booking/domain/repositories/booking_repository.dart';
import 'package:goapp/features/booking/domain/usecases/get_booking_route_usecase.dart';
import 'package:goapp/features/booking/domain/services/fare_calculator.dart';
import 'package:goapp/features/booking/domain/entities/booking_service.dart';
import 'package:goapp/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:goapp/features/booking/domain/entities/driver_info.dart';
import 'package:goapp/features/booking/domain/usecases/get_driver_info_usecase.dart';
import 'package:goapp/features/booking/domain/services/driver_arrival_estimator.dart';
import 'package:goapp/features/booking/domain/repositories/driver_repository.dart';
import 'package:goapp/features/booking/domain/services/driver_tracking_service.dart';

class FakeBookingRepository implements BookingRepository {
  bool shouldFail = false;

  @override
  Future<BookingRoute> fetchRoute({
    required GeoPoint pickup,
    required GeoPoint drop,
  }) async {
    if (shouldFail) throw Exception('failed');
    return const BookingRoute(
      encodedPolyline: 'abcd',
      distanceMeters: 2500,
      durationSeconds: 900,
    );
  }

  @override
  Future<String> bookRide({
    required BookingService vehicleType,
    required GeoPoint pickup,
    String? pickupAddress,
    required GeoPoint drop,
    String? dropAddress,
    required String encodedPolyline,
    required int distanceMeters,
    required int durationSeconds,
  }) async => 'fake-ride-id';
}

class FakeDriverRepository implements DriverRepository {
  @override
  Future<DriverInfo> fetchDriver({
    required BookingService service,
    String? rideId,
  }) async {
    return DriverInfo(
      name: 'Test Driver',
      vehicleModel: 'Test Bike',
      plateNumber: 'TN 01 ZZ 0001',
      otp: '1234',
      phone: '+91 90000 0001',
      service: service,
    );
  }
}

void main() {
  test('initial state uses provided locations', () {
    final repo = FakeBookingRepository();
    final driverRepo = FakeDriverRepository();
    final cubit = BookingCubit(
      GetBookingRouteUseCase(repo),
      fareCalculator: const FareCalculator(),
      getDriverInfoUseCase: GetDriverInfoUseCase(driverRepo),
      driverArrivalEstimator: const DriverArrivalEstimator(),
      driverTrackingService: const DriverTrackingService(
        interval: Duration(milliseconds: 10),
        steps: 2,
      ),
      pickup: const GeoPoint(lat: 12.0, lng: 77.0),
      drop: const GeoPoint(lat: 12.1, lng: 77.1),
      pickupLabel: 'Pickup',
      dropLabel: 'Drop',
      autoLoad: false,
    );

    expect(cubit.state.pickup.lat, 12.0);
    expect(cubit.state.drop.lng, 77.1);
    expect(cubit.state.loading, false);
  });

  test('loadRoute emits route data', () async {
    final repo = FakeBookingRepository();
    final driverRepo = FakeDriverRepository();
    final cubit = BookingCubit(
      GetBookingRouteUseCase(repo),
      fareCalculator: const FareCalculator(),
      getDriverInfoUseCase: GetDriverInfoUseCase(driverRepo),
      driverArrivalEstimator: const DriverArrivalEstimator(),
      driverTrackingService: const DriverTrackingService(
        interval: Duration(milliseconds: 10),
        steps: 2,
      ),
      pickup: const GeoPoint(lat: 12.0, lng: 77.0),
      drop: const GeoPoint(lat: 12.1, lng: 77.1),
      pickupLabel: 'Pickup',
      dropLabel: 'Drop',
      autoLoad: false,
    );

    await cubit.loadRoute();

    expect(cubit.state.loading, false);
    expect(cubit.state.route, isNotNull);
    expect(cubit.state.route!.distanceMeters, 2500);
    expect(cubit.state.fareQuote, isNotNull);
  });

  test('loadRoute sets error on failure', () async {
    final repo = FakeBookingRepository()..shouldFail = true;
    final driverRepo = FakeDriverRepository();
    final cubit = BookingCubit(
      GetBookingRouteUseCase(repo),
      fareCalculator: const FareCalculator(),
      getDriverInfoUseCase: GetDriverInfoUseCase(driverRepo),
      driverArrivalEstimator: const DriverArrivalEstimator(),
      driverTrackingService: const DriverTrackingService(
        interval: Duration(milliseconds: 10),
        steps: 2,
      ),
      pickup: const GeoPoint(lat: 12.0, lng: 77.0),
      drop: const GeoPoint(lat: 12.1, lng: 77.1),
      pickupLabel: 'Pickup',
      dropLabel: 'Drop',
      autoLoad: false,
    );

    await cubit.loadRoute();

    expect(cubit.state.errorMessage, isNotNull);
  });

  test('toggleService selects and deselects service', () {
    final repo = FakeBookingRepository();
    final driverRepo = FakeDriverRepository();
    final cubit = BookingCubit(
      GetBookingRouteUseCase(repo),
      fareCalculator: const FareCalculator(),
      getDriverInfoUseCase: GetDriverInfoUseCase(driverRepo),
      driverArrivalEstimator: const DriverArrivalEstimator(),
      driverTrackingService: const DriverTrackingService(
        interval: Duration(milliseconds: 10),
        steps: 2,
      ),
      pickup: const GeoPoint(lat: 12.0, lng: 77.0),
      drop: const GeoPoint(lat: 12.1, lng: 77.1),
      pickupLabel: 'Pickup',
      dropLabel: 'Drop',
      autoLoad: false,
    );

    expect(cubit.state.selectedService, isNull);

    cubit.toggleService(BookingService.bike);
    expect(cubit.state.selectedService, BookingService.bike);

    cubit.toggleService(BookingService.bike);
    expect(cubit.state.selectedService, isNull);
  });
}
