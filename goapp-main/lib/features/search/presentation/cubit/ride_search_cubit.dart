import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/services/location_service.dart';
import '../../../../core/services/location_permission_service.dart';
import '../../../../core/maps/map_view_mode.dart';
import '../../domain/entities/place_suggestion.dart';
import '../../domain/usecases/search_places_usecase.dart';
import '../../domain/usecases/reverse_geocode_usecase.dart';
import '../../domain/usecases/get_place_details_usecase.dart';
import 'ride_search_state.dart';

class RideSearchCubit extends Cubit<RideSearchState> {
  final SearchPlacesUseCase searchPlacesUseCase;
  final ReverseGeocodeUseCase reverseGeocodeUseCase;
  final GetPlaceDetailsUseCase getPlaceDetailsUseCase;
  final LocationService locationService;
  final LocationPermissionService permissionService;
  Timer? _debounce;

  RideSearchCubit(
    this.searchPlacesUseCase,
    this.reverseGeocodeUseCase,
    this.getPlaceDetailsUseCase,
    this.locationService,
    this.permissionService,
  )
      : super(RideSearchState.initial());

  void setActiveField(bool isPickup) {
    emit(
      state.copyWith(
        isPickupActive: isPickup,
        mapViewMode: isPickup ? MapViewMode.pickup : MapViewMode.drop,
        mapViewChangeId: state.mapViewChangeId + 1,
      ),
    );
    final query = isPickup ? state.pickupText : state.dropText;
    _search(query);
  }

  void updatePickup(String value) {
    emit(state.copyWith(pickupText: value));
    if (state.isPickupActive) {
      _search(value);
    }
  }

  void updateDrop(String value) {
    emit(state.copyWith(dropText: value));
    if (!state.isPickupActive) {
      _search(value);
    }
  }

  Future<void> toggleMapView() async {
    final hasBoth = state.pickupLat != null &&
        state.pickupLng != null &&
        state.dropLat != null &&
        state.dropLng != null;
    if (hasBoth) {
      final next = state.mapViewMode == MapViewMode.both
          ? MapViewMode.pickup
          : MapViewMode.both;
      emit(
        state.copyWith(
          mapViewMode: next,
          mapViewChangeId: state.mapViewChangeId + 1,
        ),
      );
      return;
    }
    if (state.pickupLat == null || state.pickupLng == null) {
      await useCurrentLocation();
      return;
    }
    emit(
      state.copyWith(
        mapViewMode: MapViewMode.pickup,
        mapViewChangeId: state.mapViewChangeId + 1,
      ),
    );
  }

  Future<void> selectSuggestion(PlaceSuggestion suggestion) async {
    if (state.isPickupActive) {
      emit(state.copyWith(pickupText: suggestion.description));
    } else {
      emit(state.copyWith(dropText: suggestion.description));
    }
    emit(state.copyWith(suggestions: const []));

    Map<String, double> details;
    try {
      details = await getPlaceDetailsUseCase(placeId: suggestion.placeId);
    } catch (_) {
      emit(state.copyWith(message: 'Unable to fetch place details'));
      return;
    }
    if (details.isEmpty) return;
    final lat = details['lat'];
    final lng = details['lng'];
    if (lat == null || lng == null) return;
    if (state.isPickupActive) {
      emit(
        state.copyWith(
          pickupLat: lat,
          pickupLng: lng,
          mapViewMode: MapViewMode.pickup,
          mapViewChangeId: state.mapViewChangeId + 1,
        ),
      );
    } else {
      emit(
        state.copyWith(
          dropLat: lat,
          dropLng: lng,
          mapViewMode: MapViewMode.drop,
          mapViewChangeId: state.mapViewChangeId + 1,
        ),
      );
    }
  }

  void clearMessage() {
    emit(state.copyWith(message: null));
  }

  void clearLocationPrompt() {
    emit(state.copyWith(needsLocationPermission: false));
  }

  Future<void> openLocationSettings() async {
    emit(
      state.copyWith(
        needsLocationPermission: false,
        pendingLocationRetry: true,
      ),
    );
    await permissionService.openSettings();
  }

  Future<void> retryIfPending() async {
    if (!state.pendingLocationRetry) return;
    emit(state.copyWith(pendingLocationRetry: false));
    await useCurrentLocation();
  }

  Future<void> useCurrentLocation() async {
    final position = await locationService.getCurrentPosition();
    if (position == null) {
      emit(
        state.copyWith(
          needsLocationPermission: true,
          locationPromptId: state.locationPromptId + 1,
          message: null,
        ),
      );
      return;
    }
    final lat = position.latitude;
    final lng = position.longitude;
    String address = '';
    String? errorMessage;
    try {
      address = await reverseGeocodeUseCase(lat: lat, lng: lng);
    } catch (_) {
      errorMessage = 'Unable to fetch address';
    }
    emit(
      state.copyWith(
        pickupText: address.isNotEmpty ? address : 'Current Location',
        suggestions: const [],
        pickupLat: lat,
        pickupLng: lng,
        needsLocationPermission: false,
        pendingLocationRetry: false,
        mapViewMode: MapViewMode.pickup,
        mapViewChangeId: state.mapViewChangeId + 1,
        message: errorMessage,
      ),
    );
  }

  Future<void> updateMarkerPosition(LatLng position) async {
    if (state.isPickupActive) {
      emit(
        state.copyWith(
          pickupLat: position.latitude,
          pickupLng: position.longitude,
          mapViewMode: MapViewMode.pickup,
          mapViewChangeId: state.mapViewChangeId + 1,
        ),
      );
    } else {
      emit(
        state.copyWith(
          dropLat: position.latitude,
          dropLng: position.longitude,
          mapViewMode: MapViewMode.drop,
          mapViewChangeId: state.mapViewChangeId + 1,
        ),
      );
    }
    String address = '';
    String? errorMessage;
    try {
      address = await reverseGeocodeUseCase(
        lat: position.latitude,
        lng: position.longitude,
      );
    } catch (_) {
      errorMessage = 'Unable to fetch address';
    }
    if (address.isEmpty) {
      if (errorMessage != null) {
        emit(state.copyWith(message: errorMessage));
      }
      return;
    }
    if (state.isPickupActive) {
      emit(state.copyWith(pickupText: address, message: errorMessage));
    } else {
      emit(state.copyWith(dropText: address, message: errorMessage));
    }
  }

  Future<void> updateMarkerPositionFor({
    required bool isPickup,
    required LatLng position,
  }) async {
    if (isPickup) {
      emit(
        state.copyWith(
          pickupLat: position.latitude,
          pickupLng: position.longitude,
          mapViewMode: MapViewMode.pickup,
          mapViewChangeId: state.mapViewChangeId + 1,
        ),
      );
    } else {
      emit(
        state.copyWith(
          dropLat: position.latitude,
          dropLng: position.longitude,
          mapViewMode: MapViewMode.drop,
          mapViewChangeId: state.mapViewChangeId + 1,
        ),
      );
    }
    String address = '';
    String? errorMessage;
    try {
      address = await reverseGeocodeUseCase(
        lat: position.latitude,
        lng: position.longitude,
      );
    } catch (_) {
      errorMessage = 'Unable to fetch address';
    }
    if (address.isEmpty) {
      if (errorMessage != null) {
        emit(state.copyWith(message: errorMessage));
      }
      return;
    }
    if (isPickup) {
      emit(state.copyWith(pickupText: address, message: errorMessage));
    } else {
      emit(state.copyWith(dropText: address, message: errorMessage));
    }
  }

  void _search(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final query = value.trim();
      if (query.isEmpty) {
        emit(state.copyWith(suggestions: const [], loading: false));
        return;
      }
      emit(state.copyWith(loading: true));
      try {
        final results = await searchPlacesUseCase(
          input: query,
          countryCode: 'in',
        );
        emit(state.copyWith(loading: false, suggestions: results));
      } catch (_) {
        emit(
          state.copyWith(
            loading: false,
            message: 'Failed to load suggestions',
          ),
        );
      }
    });
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
