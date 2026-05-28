import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/test_app.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';

import 'package:goapp/features/home/presentation/pages/home_page.dart';

class FakeGeolocatorPlatform extends GeolocatorPlatform {
  bool serviceEnabled = true;
  LocationPermission permission = LocationPermission.always;
  int openLocationSettingsCount = 0;
  int openAppSettingsCount = 0;
  int getCurrentPositionCount = 0;

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<LocationPermission> requestPermission() async => permission;

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;

  @override
  Future<Position?> getLastKnownPosition({
    bool forceLocationManager = false,
  }) async {
    return null;
  }

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    getCurrentPositionCount += 1;
    return Position(
      longitude: 77.0,
      latitude: 12.0,
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

  @override
  Stream<Position> getPositionStream({
    LocationSettings? locationSettings,
  }) {
    return const Stream.empty();
  }

  @override
  Stream<ServiceStatus> getServiceStatusStream() {
    return const Stream.empty();
  }

  @override
  Future<LocationAccuracyStatus> requestTemporaryFullAccuracy({
    required String purposeKey,
  }) async {
    return LocationAccuracyStatus.precise;
  }

  @override
  Future<LocationAccuracyStatus> getLocationAccuracy() async {
    return LocationAccuracyStatus.precise;
  }

  @override
  Future<bool> openAppSettings() async {
    openAppSettingsCount += 1;
    return true;
  }

  @override
  Future<bool> openLocationSettings() async {
    openLocationSettingsCount += 1;
    return true;
  }
}

void main() {
  late GeolocatorPlatform original;

  setUp(() {
    original = GeolocatorPlatform.instance;
  });

  tearDown(() {
    GeolocatorPlatform.instance = original;
  });

  testWidgets('opens location settings when service is disabled',
      (tester) async {
    final fakePlatform = FakeGeolocatorPlatform()
      ..serviceEnabled = false
      ..permission = LocationPermission.denied;
    GeolocatorPlatform.instance = fakePlatform;

    await tester.pumpWidget(
      const TestApp(
        home: HomePage(),
      ),
    );

    await tester.tap(find.byIcon(Icons.my_location), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Please allow location'), findsOneWidget);
    await tester.tap(find.text('Open Settings'));
    await tester.pumpAndSettle();

    expect(fakePlatform.openLocationSettingsCount, 1);
  });

  testWidgets('opens app settings when permission denied and retries on resume',
      (tester) async {
    final fakePlatform = FakeGeolocatorPlatform()
      ..serviceEnabled = true
      ..permission = LocationPermission.denied;
    GeolocatorPlatform.instance = fakePlatform;

    await tester.pumpWidget(
      const TestApp(
        home: HomePage(),
      ),
    );

    await tester.tap(find.byIcon(Icons.my_location), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Please allow location'), findsOneWidget);
    await tester.tap(find.text('Open Settings'));
    await tester.pumpAndSettle();

    expect(fakePlatform.openAppSettingsCount, 1);

    fakePlatform.permission = LocationPermission.whileInUse;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(fakePlatform.getCurrentPositionCount, 1);
  });
}