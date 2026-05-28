import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/test_app.dart';

import 'package:goapp/features/booking/domain/entities/booking_route.dart';
import 'package:goapp/features/booking/domain/entities/geo_point.dart';
import 'package:goapp/features/booking/domain/entities/fare_quote.dart';
import 'package:goapp/features/booking/domain/entities/booking_service.dart';
import 'package:goapp/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:goapp/features/booking/presentation/pages/booking_page.dart';
import 'package:goapp/features/booking/domain/usecases/get_booking_route_usecase.dart';
import 'package:goapp/features/booking/domain/repositories/booking_repository.dart';
import 'package:goapp/features/booking/domain/services/fare_calculator.dart';
import 'package:goapp/core/maps/map_view_mode.dart';
import 'package:goapp/features/booking/domain/entities/driver_info.dart';
import 'package:goapp/features/booking/domain/usecases/get_driver_info_usecase.dart';
import 'package:goapp/features/booking/domain/services/driver_arrival_estimator.dart';
import 'package:goapp/features/booking/domain/repositories/driver_repository.dart';
import 'package:goapp/features/booking/domain/services/driver_tracking_service.dart';
import 'package:goapp/core/di/injection.dart';
import 'package:goapp/core/services/notification_permission_service.dart';
import 'package:goapp/features/booking/presentation/widgets/booking_map_section.dart';
import 'package:goapp/features/booking/domain/entities/driver_search_status.dart';
import 'package:goapp/features/payment/presentation/pages/payment_page.dart';
import 'package:goapp/features/feedback/presentation/pages/feedback_page.dart';
import 'package:goapp/features/home/presentation/pages/home_page.dart';

class FakeNotificationPermissionService
    implements NotificationPermissionService {
  NotificationPermissionStatus checkStatus;
  NotificationPermissionStatus requestStatus;
  int openSettingsCount = 0;
  int requestCount = 0;
  int checkCount = 0;

  FakeNotificationPermissionService({
    required this.checkStatus,
    required this.requestStatus,
  });

  @override
  Future<NotificationPermissionStatus> check() async {
    checkCount += 1;
    return checkStatus;
  }

  @override
  Future<NotificationPermissionStatus> request() async {
    requestCount += 1;
    return requestStatus;
  }

  @override
  Future<bool> openSettings() async {
    openSettingsCount += 1;
    return true;
  }
}

class FakeBookingRepository implements BookingRepository {
  @override
  Future<BookingRoute> fetchRoute({
    required GeoPoint pickup,
    required GeoPoint drop,
  }) async {
    return const BookingRoute(
      encodedPolyline: '',
      distanceMeters: 3000,
      durationSeconds: 600,
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
  void registerNotificationService(NotificationPermissionService service) {
    if (getIt.isRegistered<NotificationPermissionService>()) {
      getIt.unregister<NotificationPermissionService>();
    }
    getIt.registerLazySingleton<NotificationPermissionService>(() => service);
  }

  testWidgets('map disabled in tests placeholder is shown', (tester) async {
    final cubit = BookingCubit(
      GetBookingRouteUseCase(FakeBookingRepository()),
      fareCalculator: const FareCalculator(),
      getDriverInfoUseCase: GetDriverInfoUseCase(FakeDriverRepository()),
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

    await tester.pumpWidget(
      TestApp(
        home: BookingPage(
          pickup: const GeoPoint(lat: 12.0, lng: 77.0),
          drop: const GeoPoint(lat: 12.1, lng: 77.1),
          pickupLabel: 'Pickup',
          dropLabel: 'Drop',
          cubit: cubit,
          isTestOverride: true,
        ),
      ),
    );

    expect(find.byKey(const Key('booking-map-placeholder')), findsOneWidget);
  });

  testWidgets('shows distance and ETA when route loaded', (tester) async {
    final cubit = BookingCubit(
      GetBookingRouteUseCase(FakeBookingRepository()),
      fareCalculator: const FareCalculator(),
      getDriverInfoUseCase: GetDriverInfoUseCase(FakeDriverRepository()),
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

    await tester.pumpWidget(
      TestApp(
        home: BookingPage(
          pickup: const GeoPoint(lat: 12.0, lng: 77.0),
          drop: const GeoPoint(lat: 12.1, lng: 77.1),
          pickupLabel: 'Pickup',
          dropLabel: 'Drop',
          cubit: cubit,
          isTestOverride: true,
        ),
      ),
    );

    cubit.emit(
      cubit.state.copyWith(
        route: const BookingRoute(
          encodedPolyline: '',
          distanceMeters: 5000,
          durationSeconds: 900,
        ),
        distanceKm: 5.0,
        durationMin: 15,
        fareQuote: const FareQuote(
          baseFare: 120,
          servicePrices: {
            BookingService.bike: 96,
            BookingService.auto: 120,
            BookingService.car: 156,
          },
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Booking Summary'), findsOneWidget);
    expect(find.text('Distance: 5.0 km'), findsOneWidget);
    expect(find.text('ETA: 15 min'), findsOneWidget);
    expect(find.text('Estimated fare: Rs 120'), findsOneWidget);
    expect(find.text('Select Service'), findsOneWidget);
    expect(find.text('Bike'), findsOneWidget);
    expect(find.text('Auto'), findsOneWidget);
    expect(find.text('Car'), findsOneWidget);
  });

  testWidgets('locks service selection when initial service is provided',
      (tester) async {
    final cubit = BookingCubit(
      GetBookingRouteUseCase(FakeBookingRepository()),
      fareCalculator: const FareCalculator(),
      getDriverInfoUseCase: GetDriverInfoUseCase(FakeDriverRepository()),
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
      initialService: BookingService.bike,
    );

    await tester.pumpWidget(
      TestApp(
        home: BookingPage(
          pickup: const GeoPoint(lat: 12.0, lng: 77.0),
          drop: const GeoPoint(lat: 12.1, lng: 77.1),
          pickupLabel: 'Pickup',
          dropLabel: 'Drop',
          cubit: cubit,
          initialService: BookingService.bike,
          isTestOverride: true,
        ),
      ),
    );

    cubit.emit(
      cubit.state.copyWith(
        route: const BookingRoute(
          encodedPolyline: '',
          distanceMeters: 5000,
          durationSeconds: 900,
        ),
        distanceKm: 5.0,
        durationMin: 15,
        fareQuote: const FareQuote(
          baseFare: 120,
          servicePrices: {
            BookingService.bike: 96,
            BookingService.auto: 120,
            BookingService.car: 156,
          },
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Bike'), findsOneWidget);
    expect(find.text('Auto'), findsNothing);
    expect(find.text('Car'), findsNothing);
  });

  testWidgets('map toggle button shows zoom icon by default', (tester) async {
    final cubit = BookingCubit(
      GetBookingRouteUseCase(FakeBookingRepository()),
      fareCalculator: const FareCalculator(),
      getDriverInfoUseCase: GetDriverInfoUseCase(FakeDriverRepository()),
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

    await tester.pumpWidget(
      TestApp(
        home: BookingPage(
          pickup: const GeoPoint(lat: 12.0, lng: 77.0),
          drop: const GeoPoint(lat: 12.1, lng: 77.1),
          pickupLabel: 'Pickup',
          dropLabel: 'Drop',
          cubit: cubit,
          isTestOverride: true,
        ),
      ),
    );

    expect(find.widgetWithIcon(FloatingActionButton, Icons.zoom_out_map),
        findsOneWidget);
  });

  testWidgets('map toggle button switches icon when tapped', (tester) async {
    final cubit = BookingCubit(
      GetBookingRouteUseCase(FakeBookingRepository()),
      fareCalculator: const FareCalculator(),
      getDriverInfoUseCase: GetDriverInfoUseCase(FakeDriverRepository()),
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

    await tester.pumpWidget(
      TestApp(
        home: BookingPage(
          pickup: const GeoPoint(lat: 12.0, lng: 77.0),
          drop: const GeoPoint(lat: 12.1, lng: 77.1),
          pickupLabel: 'Pickup',
          dropLabel: 'Drop',
          cubit: cubit,
          isTestOverride: true,
        ),
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(cubit.state.mapViewMode, MapViewMode.both);
    final fabAfterFirstTap =
        tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
    expect((fabAfterFirstTap.child as Icon).icon, Icons.my_location);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(cubit.state.mapViewMode, MapViewMode.pickup);
    final fabAfterSecondTap =
        tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
    expect((fabAfterSecondTap.child as Icon).icon, Icons.zoom_out_map);
  });

  testWidgets('driver search shows sheet then found dialog', (tester) async {
    final cubit = BookingCubit(
      GetBookingRouteUseCase(FakeBookingRepository()),
      fareCalculator: const FareCalculator(),
      getDriverInfoUseCase: GetDriverInfoUseCase(FakeDriverRepository()),
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

    await tester.pumpWidget(
      TestApp(
        home: BookingPage(
          pickup: const GeoPoint(lat: 12.0, lng: 77.0),
          drop: const GeoPoint(lat: 12.1, lng: 77.1),
          pickupLabel: 'Pickup',
          dropLabel: 'Drop',
          cubit: cubit,
          isTestOverride: true,
        ),
      ),
    );

    cubit.emit(
      cubit.state.copyWith(
        selectedService: BookingService.bike,
        route: const BookingRoute(
          encodedPolyline: '',
          distanceMeters: 1200,
          durationSeconds: 600,
        ),
        distanceKm: 1.2,
        durationMin: 10,
        fareQuote: const FareQuote(
          baseFare: 120,
          servicePrices: {
            BookingService.bike: 96,
            BookingService.auto: 120,
            BookingService.car: 156,
          },
        ),
      ),
    );
    await tester.pump();

    final button =
        tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Book Now'));
    expect(button.onPressed, isNotNull);

    cubit.startDriverSearch();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Searching for a driver'), findsOneWidget);
    expect(find.byIcon(Icons.directions_bike), findsOneWidget);

    await tester.pump(const Duration(seconds: 10));
    await tester.pump();

    expect(find.text('Driver accepted your ride'), findsOneWidget);
    expect(find.text('Your driver is on the way.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Driver accepted your ride'), findsNothing);
    expect(find.text('Reached your location'), findsOneWidget);
    expect(find.text('Thanks for riding with us.'), findsOneWidget);
    expect(find.text('Booking Summary'), findsNothing);
    expect(find.text('Driver arriving'), findsNothing);
    expect(find.text('Pickup'), findsWidgets);
    expect(find.text('Drop'), findsWidgets);
    expect(find.text('Test Driver'), findsOneWidget);
    expect(find.textContaining('Test Bike'), findsOneWidget);
    expect(find.text('1234'), findsOneWidget);
    expect(find.textContaining('Total fare'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Pay Now'), findsOneWidget);
  });

  testWidgets('vehicle markers only shown while searching', (tester) async {
    final cubit = BookingCubit(
      GetBookingRouteUseCase(FakeBookingRepository()),
      fareCalculator: const FareCalculator(),
      getDriverInfoUseCase: GetDriverInfoUseCase(FakeDriverRepository()),
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

    await tester.pumpWidget(
      TestApp(
        home: BookingPage(
          pickup: const GeoPoint(lat: 12.0, lng: 77.0),
          drop: const GeoPoint(lat: 12.1, lng: 77.1),
          pickupLabel: 'Pickup',
          dropLabel: 'Drop',
          cubit: cubit,
          isTestOverride: true,
        ),
      ),
    );

    BookingMapSection mapSection =
        tester.widget<BookingMapSection>(find.byType(BookingMapSection));
    expect(mapSection.vehicleMarkers.isEmpty, true);

    cubit.emit(
      cubit.state.copyWith(
        driverSearchStatus: DriverSearchStatus.searching,
      ),
    );
    await tester.pump();

    mapSection =
        tester.widget<BookingMapSection>(find.byType(BookingMapSection));
    expect(mapSection.vehicleMarkers.isNotEmpty, true);

    cubit.emit(
      cubit.state.copyWith(
        driverSearchStatus: DriverSearchStatus.arriving,
      ),
    );
    await tester.pump();

    mapSection =
        tester.widget<BookingMapSection>(find.byType(BookingMapSection));
    expect(mapSection.vehicleMarkers.isEmpty, true);
  });

  testWidgets('pay now flows to payment, feedback, then home', (tester) async {
    final cubit = BookingCubit(
      GetBookingRouteUseCase(FakeBookingRepository()),
      fareCalculator: const FareCalculator(),
      getDriverInfoUseCase: GetDriverInfoUseCase(FakeDriverRepository()),
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

    await tester.pumpWidget(
      TestApp(
        home: BookingPage(
          pickup: const GeoPoint(lat: 12.0, lng: 77.0),
          drop: const GeoPoint(lat: 12.1, lng: 77.1),
          pickupLabel: 'Pickup',
          dropLabel: 'Drop',
          cubit: cubit,
          isTestOverride: true,
        ),
      ),
    );

    cubit.emit(
      cubit.state.copyWith(
        driverSearchStatus: DriverSearchStatus.completed,
        driverInfo: DriverInfo(
          name: 'Test Driver',
          vehicleModel: 'Test Bike',
          plateNumber: 'TN 01 ZZ 0001',
          otp: '1234',
          phone: '+91 90000 0001',
          service: BookingService.bike,
        ),
        distanceKm: 2.4,
        durationMin: 12,
        fareQuote: const FareQuote(
          baseFare: 120,
          servicePrices: {BookingService.bike: 96},
        ),
        selectedFare: 96,
      ),
    );
    await tester.pump();

    expect(find.widgetWithText(ElevatedButton, 'Pay Now'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Pay Now'));
    await tester.pumpAndSettle();

    expect(find.byType(PaymentPage), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Pay Now'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Payment Successful'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.byType(FeedbackPage), findsOneWidget);
    await tester.ensureVisible(find.text('Skip'));
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('book now shows notification sheet when denied', (tester) async {
    final permissionService = FakeNotificationPermissionService(
      checkStatus: NotificationPermissionStatus.denied,
      requestStatus: NotificationPermissionStatus.denied,
    );
    registerNotificationService(permissionService);

    final cubit = BookingCubit(
      GetBookingRouteUseCase(FakeBookingRepository()),
      fareCalculator: const FareCalculator(),
      getDriverInfoUseCase: GetDriverInfoUseCase(FakeDriverRepository()),
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

    await tester.pumpWidget(
      TestApp(
        home: BookingPage(
          pickup: const GeoPoint(lat: 12.0, lng: 77.0),
          drop: const GeoPoint(lat: 12.1, lng: 77.1),
          pickupLabel: 'Pickup',
          dropLabel: 'Drop',
          cubit: cubit,
          isTestOverride: true,
        ),
      ),
    );

    cubit.emit(
      cubit.state.copyWith(
        selectedService: BookingService.bike,
        route: const BookingRoute(
          encodedPolyline: '',
          distanceMeters: 1200,
          durationSeconds: 600,
        ),
        distanceKm: 1.2,
        durationMin: 10,
        fareQuote: const FareQuote(
          baseFare: 120,
          servicePrices: {
            BookingService.bike: 96,
            BookingService.auto: 120,
            BookingService.car: 156,
          },
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Book Now'));
    await tester.pumpAndSettle();

    expect(find.text('Enable notifications'), findsOneWidget);
    expect(find.text('Allow'), findsOneWidget);
  });

  testWidgets('opens settings after two notification denies', (tester) async {
    final permissionService = FakeNotificationPermissionService(
      checkStatus: NotificationPermissionStatus.denied,
      requestStatus: NotificationPermissionStatus.denied,
    );
    registerNotificationService(permissionService);

    final cubit = BookingCubit(
      GetBookingRouteUseCase(FakeBookingRepository()),
      fareCalculator: const FareCalculator(),
      getDriverInfoUseCase: GetDriverInfoUseCase(FakeDriverRepository()),
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

    await tester.pumpWidget(
      TestApp(
        home: BookingPage(
          pickup: const GeoPoint(lat: 12.0, lng: 77.0),
          drop: const GeoPoint(lat: 12.1, lng: 77.1),
          pickupLabel: 'Pickup',
          dropLabel: 'Drop',
          cubit: cubit,
          isTestOverride: true,
        ),
      ),
    );

    cubit.emit(
      cubit.state.copyWith(
        selectedService: BookingService.bike,
        route: const BookingRoute(
          encodedPolyline: '',
          distanceMeters: 1200,
          durationSeconds: 600,
        ),
        distanceKm: 1.2,
        durationMin: 10,
        fareQuote: const FareQuote(
          baseFare: 120,
          servicePrices: {
            BookingService.bike: 96,
            BookingService.auto: 120,
            BookingService.car: 156,
          },
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Book Now'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Allow'));
    await tester.pumpAndSettle();

    expect(permissionService.openSettingsCount, 0);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Book Now'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Allow'));
    await tester.pumpAndSettle();

    expect(permissionService.openSettingsCount, 1);
  });
}
