import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import 'package:goapp/core/services/location_service.dart';
import 'package:goapp/core/services/location_permission_service.dart';
import 'package:goapp/features/search/domain/entities/place_suggestion.dart';
import 'package:goapp/features/search/domain/repositories/places_repository.dart';
import 'package:goapp/features/search/domain/usecases/search_places_usecase.dart';
import 'package:goapp/features/search/domain/usecases/reverse_geocode_usecase.dart';
import 'package:goapp/features/search/domain/usecases/get_place_details_usecase.dart';
import 'package:goapp/features/search/presentation/cubit/ride_search_cubit.dart';
import 'package:goapp/features/search/presentation/cubit/ride_search_state.dart';

class FakePlacesRepository implements PlacesRepository {
  List<PlaceSuggestion> result = [];
  int calls = 0;
  String reverseResult = 'Address';

  @override
  Future<List<PlaceSuggestion>> autocomplete({
    required String input,
    String? countryCode,
  }) async {
    calls += 1;
    return result;
  }

  @override
  Future<String> reverseGeocode({
    required double lat,
    required double lng,
  }) async {
    return reverseResult;
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

  @override
  Future<bool> canUseCurrentLocation() async => canUse;

  @override
  Future<Position?> getCurrentPosition() async {
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

class FakeLocationPermissionService implements LocationPermissionService {
  @override
  Future<LocationPermissionStatus> requestWhenInUse() async {
    return LocationPermissionStatus.granted;
  }

  @override
  Future<bool> openSettings() async {
    return true;
  }
}

RideSearchCubit _buildCubit({
  FakePlacesRepository? repo,
  FakeLocationService? location,
}) {
  final placesRepo = repo ?? FakePlacesRepository();
  return RideSearchCubit(
    SearchPlacesUseCase(placesRepo),
    ReverseGeocodeUseCase(placesRepo),
    GetPlaceDetailsUseCase(placesRepo),
    location ?? FakeLocationService(),
    FakeLocationPermissionService(),
  );
}

void main() {
  test('initial state', () {
    final cubit = _buildCubit();
    expect(cubit.state, isA<RideSearchState>());
    expect(cubit.state.pickupText, '');
    expect(cubit.state.dropText, '');
    expect(cubit.state.loading, false);
  });

  test('setActiveField toggles pickup/drop', () {
    final cubit = _buildCubit();
    cubit.setActiveField(false);
    expect(cubit.state.isPickupActive, false);
    cubit.setActiveField(true);
    expect(cubit.state.isPickupActive, true);
  });

  test('updatePickup updates pickup text', () async {
    final cubit = _buildCubit();
    cubit.updatePickup('MG');
    expect(cubit.state.pickupText, 'MG');
  });

  test('updateDrop updates drop text', () async {
    final cubit = _buildCubit();
    cubit.updateDrop('Brigade');
    expect(cubit.state.dropText, 'Brigade');
  });

  test('useCurrentLocation sets pickup text when allowed', () async {
    final location = FakeLocationService()..canUse = true;
    final cubit = _buildCubit(location: location);
    await cubit.useCurrentLocation();
    expect(cubit.state.pickupText, 'Address');
    expect(cubit.state.pickupLat, isNotNull);
    expect(cubit.state.pickupLng, isNotNull);
  });

  test('useCurrentLocation shows message when not allowed', () async {
    final location = FakeLocationService()..canUse = false;
    final cubit = _buildCubit(location: location);
    await cubit.useCurrentLocation();
    expect(cubit.state.needsLocationPermission, true);
  });

  test('empty query clears suggestions', () async {
    final repo = FakePlacesRepository()
      ..result = [
        PlaceSuggestion(description: 'A', placeId: '1'),
      ];
    final cubit = _buildCubit(repo: repo);
    cubit.updatePickup('A');
    await Future<void>.delayed(const Duration(milliseconds: 400));
    expect(cubit.state.suggestions, isNotEmpty);

    cubit.updatePickup('');
    await Future<void>.delayed(const Duration(milliseconds: 400));
    expect(cubit.state.suggestions, isEmpty);
  });

  test('search emits suggestions after debounce', () async {
    final repo = FakePlacesRepository()
      ..result = [
        PlaceSuggestion(description: 'A', placeId: '1'),
      ];
    final cubit = _buildCubit(repo: repo);
    cubit.updatePickup('A');
    await Future<void>.delayed(const Duration(milliseconds: 400));
    expect(repo.calls, 1);
    expect(cubit.state.suggestions.length, 1);
  });

  test('canContinue is true when pickup and drop are set', () async {
    final cubit = _buildCubit();

    expect(cubit.state.canContinue, false);

    cubit.emit(
      cubit.state.copyWith(
        pickupLat: 12.0,
        pickupLng: 77.0,
        dropLat: 12.1,
        dropLng: 77.1,
      ),
    );

    expect(cubit.state.canContinue, true);
  });
}
