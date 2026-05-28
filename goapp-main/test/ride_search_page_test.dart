import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/test_app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import 'package:goapp/features/search/domain/entities/place_suggestion.dart';
import 'package:goapp/features/search/domain/repositories/places_repository.dart';
import 'package:goapp/features/search/domain/usecases/search_places_usecase.dart';
import 'package:goapp/features/search/presentation/pages/ride_search_page.dart';
import 'package:goapp/features/search/presentation/cubit/ride_search_cubit.dart';
import 'package:goapp/core/services/location_service.dart';
import 'package:goapp/core/services/location_permission_service.dart';
import 'package:goapp/features/search/domain/usecases/reverse_geocode_usecase.dart';
import 'package:goapp/features/search/domain/usecases/get_place_details_usecase.dart';
import 'package:goapp/core/di/injection.dart';
import 'package:goapp/features/booking/domain/entities/booking_route.dart';
import 'package:goapp/features/booking/domain/entities/geo_point.dart';
import 'package:goapp/features/booking/domain/repositories/booking_repository.dart';
import 'package:goapp/features/booking/domain/usecases/get_booking_route_usecase.dart';
import 'package:goapp/features/booking/domain/entities/booking_service.dart';
import 'package:goapp/core/maps/app_google_map.dart';
import 'package:goapp/core/maps/map_view_mode.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

int _vehicleMarkerCount(Set<Marker> markers) {
  return markers
      .where((marker) {
        final id = marker.markerId.value;
        return id.startsWith('Bike_') ||
            id.startsWith('Auto_') ||
            id.startsWith('Car_');
      })
      .length;
}

class FakePlacesRepository implements PlacesRepository {
  int calls = 0;
  String lastQuery = '';

  @override
  Future<List<PlaceSuggestion>> autocomplete({
    required String input,
    String? countryCode,
  }) async {
    calls += 1;
    lastQuery = input;
    return [
      PlaceSuggestion(description: 'MG Road', placeId: '1'),
      PlaceSuggestion(description: 'Brigade Road', placeId: '2'),
    ];
  }

  @override
  Future<String> reverseGeocode({
    required double lat,
    required double lng,
  }) async {
    return 'Some Address';
  }

  @override
  Future<Map<String, double>> placeDetails({
    required String placeId,
  }) async {
    return {'lat': 12.0, 'lng': 77.0};
  }
}

class FakeLocationService extends LocationService {
  bool canUse = true;
  double lat = 12.0;
  double lng = 77.0;
  int getCurrentCalls = 0;

  @override
  Future<bool> canUseCurrentLocation() async => canUse;

  @override
  Future<Position?> getCurrentPosition() async {
    getCurrentCalls += 1;
    if (!canUse) return null;
    return Position(
      longitude: lng,
      latitude: lat,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
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
      distanceMeters: 1200,
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

class FakeLocationPermissionService implements LocationPermissionService {
  int openSettingsCount = 0;
  LocationPermissionStatus statusToReturn =
      LocationPermissionStatus.granted;

  @override
  Future<LocationPermissionStatus> requestWhenInUse() async {
    return statusToReturn;
  }

  @override
  Future<bool> openSettings() async {
    openSettingsCount += 1;
    return true;
  }
}

RideSearchCubit _buildCubit({
  FakePlacesRepository? repo,
  FakeLocationService? locationService,
  FakeLocationPermissionService? permissionService,
}) {
  final placesRepo = repo ?? FakePlacesRepository();
  return RideSearchCubit(
    SearchPlacesUseCase(placesRepo),
    ReverseGeocodeUseCase(placesRepo),
    GetPlaceDetailsUseCase(placesRepo),
    locationService ?? FakeLocationService(),
    permissionService ?? FakeLocationPermissionService(),
  );
}

void main() {
  testWidgets('shows suggestions when typing', (tester) async {
    final repo = FakePlacesRepository();
    final cubit = _buildCubit(repo: repo);

    await tester.pumpWidget(
      TestApp(
        home: BlocProvider.value(
          value: cubit,
          child: const RideSearchPage(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'MG');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(find.text('MG Road'), findsOneWidget);
    expect(find.text('Brigade Road'), findsOneWidget);
    expect(repo.calls, 1);
    expect(repo.lastQuery, 'MG');
  });

  testWidgets('empty query clears suggestions', (tester) async {
    final repo = FakePlacesRepository();
    final cubit = _buildCubit(repo: repo);

    await tester.pumpWidget(
      TestApp(
        home: BlocProvider.value(
          value: cubit,
          child: const RideSearchPage(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'MG');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(find.text('MG Road'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(find.text('MG Road'), findsNothing);
  });

  testWidgets('pickup and drop focus switching', (tester) async {
    final repo = FakePlacesRepository();
    final cubit = _buildCubit(repo: repo);

    await tester.pumpWidget(
      TestApp(
        home: BlocProvider.value(
          value: cubit,
          child: const RideSearchPage(),
        ),
      ),
    );

    await tester.tap(find.byType(TextField).first);
    await tester.enterText(find.byType(TextField).first, 'MG');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(repo.lastQuery, 'MG');

    await tester.tap(find.byType(TextField).at(1));
    await tester.enterText(find.byType(TextField).at(1), 'Br');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(repo.lastQuery, 'Br');
  });

  testWidgets('use current location tap sets pickup text', (tester) async {
    final repo = FakePlacesRepository();
    final locationService = FakeLocationService();
    final cubit = _buildCubit(
      repo: repo,
      locationService: locationService,
    );

    await tester.pumpWidget(
      TestApp(
        home: BlocProvider.value(
          value: cubit,
          child: const RideSearchPage(),
        ),
      ),
    );

    await tester.tap(find.text('Use current location'));
    await tester.pump();

    expect(find.text('Some Address'), findsOneWidget);
  });

  testWidgets('continue button appears after both locations set',
      (tester) async {
    final repo = FakePlacesRepository();
    final cubit = _buildCubit(repo: repo);

    await tester.pumpWidget(
      TestApp(
        home: BlocProvider.value(
          value: cubit,
          child: const RideSearchPage(),
        ),
      ),
    );

    expect(find.text('Continue'), findsNothing);

    cubit.emit(
      cubit.state.copyWith(
        pickupLat: 12.0,
        pickupLng: 77.0,
        dropLat: 12.1,
        dropLng: 77.1,
      ),
    );
    await tester.pump();

    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('continue navigates to booking page', (tester) async {
    if (getIt.isRegistered<GetBookingRouteUseCase>()) {
      getIt.unregister<GetBookingRouteUseCase>();
    }
    getIt.registerLazySingleton<GetBookingRouteUseCase>(
      () => GetBookingRouteUseCase(FakeBookingRepository()),
    );

    final repo = FakePlacesRepository();
    final cubit = _buildCubit(repo: repo);

    await tester.pumpWidget(
      TestApp(
        home: BlocProvider.value(
          value: cubit,
          child: const RideSearchPage(),
        ),
      ),
    );

    cubit.emit(
      cubit.state.copyWith(
        pickupLat: 12.0,
        pickupLng: 77.0,
        dropLat: 12.1,
        dropLng: 77.1,
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Booking'), findsOneWidget);
  });

  testWidgets('continue locks selected service when provided',
      (tester) async {
    if (getIt.isRegistered<GetBookingRouteUseCase>()) {
      getIt.unregister<GetBookingRouteUseCase>();
    }
    getIt.registerLazySingleton<GetBookingRouteUseCase>(
      () => GetBookingRouteUseCase(FakeBookingRepository()),
    );

    final repo = FakePlacesRepository();
    final cubit = _buildCubit(repo: repo);

    await tester.pumpWidget(
      TestApp(
        home: BlocProvider.value(
          value: cubit,
          child: const RideSearchPage(
            initialService: BookingService.bike,
          ),
        ),
      ),
    );

    cubit.emit(
      cubit.state.copyWith(
        pickupLat: 12.0,
        pickupLng: 77.0,
        dropLat: 12.1,
        dropLng: 77.1,
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Bike'), findsOneWidget);
    expect(find.text('Auto'), findsNothing);
    expect(find.text('Car'), findsNothing);
  });

  testWidgets('shows location dialog and retries after settings',
      (tester) async {
    final repo = FakePlacesRepository();
    final locationService = FakeLocationService()..canUse = false;
    final permissionService = FakeLocationPermissionService();
    final cubit = _buildCubit(
      repo: repo,
      locationService: locationService,
      permissionService: permissionService,
    );

    await tester.pumpWidget(
      TestApp(
        home: BlocProvider.value(
          value: cubit,
          child: const RideSearchPage(),
        ),
      ),
    );

    await tester.tap(find.text('Use current location'));
    await tester.pumpAndSettle();

    expect(find.text('Please allow location'), findsOneWidget);
    await tester.tap(find.text('Open Settings'));
    await tester.pumpAndSettle();
    expect(permissionService.openSettingsCount, 1);

    locationService.canUse = true;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(find.text('Some Address'), findsOneWidget);

  });

  testWidgets(
      'pickup center falls back to current location when pickup missing',
      (tester) async {
    final repo = FakePlacesRepository();
    final locationService = FakeLocationService();
    final cubit = _buildCubit(
      repo: repo,
      locationService: locationService,
    );

    await tester.pumpWidget(
      TestApp(
        home: BlocProvider.value(
          value: cubit,
          child: const RideSearchPage(),
        ),
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Some Address'), findsOneWidget);
    expect(locationService.getCurrentCalls, 1);

  });

  testWidgets('pickup center uses existing pickup without fetching location',
      (tester) async {
    final repo = FakePlacesRepository();
    final locationService = FakeLocationService();
    final cubit = _buildCubit(
      repo: repo,
      locationService: locationService,
    );

    await tester.pumpWidget(
      TestApp(
        home: BlocProvider.value(
          value: cubit,
          child: const RideSearchPage(),
        ),
      ),
    );

    cubit.emit(
      cubit.state.copyWith(
        pickupLat: 12.0,
        pickupLng: 77.0,
        pickupText: 'Existing Pickup',
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    expect(locationService.getCurrentCalls, 0);
  });

  testWidgets('pickup center shows zoom icon when both locations set',
      (tester) async {
    final repo = FakePlacesRepository();
    final locationService = FakeLocationService();
    final cubit = _buildCubit(
      repo: repo,
      locationService: locationService,
    );

    await tester.pumpWidget(
      TestApp(
        home: BlocProvider.value(
          value: cubit,
          child: const RideSearchPage(),
        ),
      ),
    );

    cubit.emit(
      cubit.state.copyWith(
        pickupLat: 12.0,
        pickupLng: 77.0,
        dropLat: 12.1,
        dropLng: 77.1,
      ),
    );
    await tester.pump();

    expect(find.widgetWithIcon(FloatingActionButton, Icons.zoom_out_map),
        findsOneWidget);
  });

  testWidgets('pickup center does not fetch location when both set',
      (tester) async {
    final repo = FakePlacesRepository();
    final locationService = FakeLocationService();
    final cubit = _buildCubit(
      repo: repo,
      locationService: locationService,
    );

    await tester.pumpWidget(
      TestApp(
        home: BlocProvider.value(
          value: cubit,
          child: const RideSearchPage(),
        ),
      ),
    );

    cubit.emit(
      cubit.state.copyWith(
        pickupLat: 12.0,
        pickupLng: 77.0,
        dropLat: 12.1,
        dropLng: 77.1,
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    expect(locationService.getCurrentCalls, 0);
  });

  testWidgets('pickup center toggles icon when both locations set',
      (tester) async {
    final repo = FakePlacesRepository();
    final locationService = FakeLocationService();
    final cubit = _buildCubit(
      repo: repo,
      locationService: locationService,
    );

    await tester.pumpWidget(
      TestApp(
        home: BlocProvider.value(
          value: cubit,
          child: const RideSearchPage(),
        ),
      ),
    );

    cubit.emit(
      cubit.state.copyWith(
        pickupLat: 12.0,
        pickupLng: 77.0,
        dropLat: 12.1,
        dropLng: 77.1,
      ),
    );
    await tester.pump();

    expect(find.widgetWithIcon(FloatingActionButton, Icons.zoom_out_map),
        findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    expect(find.widgetWithIcon(FloatingActionButton, Icons.my_location),
        findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    expect(find.widgetWithIcon(FloatingActionButton, Icons.zoom_out_map),
        findsOneWidget);
  });

  testWidgets('vehicle markers only shown when map view is both',
      (tester) async {
    final repo = FakePlacesRepository();
    final cubit = _buildCubit(repo: repo);

    await tester.pumpWidget(
      TestApp(
        home: BlocProvider.value(
          value: cubit,
          child: const RideSearchPage(),
        ),
      ),
    );

    cubit.emit(
      cubit.state.copyWith(
        pickupLat: 12.0,
        pickupLng: 77.0,
        mapViewMode: MapViewMode.both,
        mapViewChangeId: cubit.state.mapViewChangeId + 1,
      ),
    );
    await tester.pumpAndSettle();

    final mapBoth = tester.widget<AppGoogleMap>(find.byType(AppGoogleMap));
    expect(_vehicleMarkerCount(mapBoth.markers), greaterThan(0));

    cubit.emit(
      cubit.state.copyWith(
        mapViewMode: MapViewMode.pickup,
        mapViewChangeId: cubit.state.mapViewChangeId + 1,
      ),
    );
    await tester.pumpAndSettle();

    final mapPickup = tester.widget<AppGoogleMap>(find.byType(AppGoogleMap));
    expect(_vehicleMarkerCount(mapPickup.markers), 0);
  });

}