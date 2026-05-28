import '../../domain/entities/place_suggestion.dart';
import '../../../../core/maps/map_view_mode.dart';

class RideSearchState {
  final String pickupText;
  final String dropText;
  final bool isPickupActive;
  final bool loading;
  final List<PlaceSuggestion> suggestions;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropLat;
  final double? dropLng;
  final String? message;
  final bool needsLocationPermission;
  final int locationPromptId;
  final bool pendingLocationRetry;
  final MapViewMode mapViewMode;
  final int mapViewChangeId;

  const RideSearchState({
    required this.pickupText,
    required this.dropText,
    required this.isPickupActive,
    required this.loading,
    required this.suggestions,
    this.pickupLat,
    this.pickupLng,
    this.dropLat,
    this.dropLng,
    this.message,
    required this.needsLocationPermission,
    required this.locationPromptId,
    required this.pendingLocationRetry,
    required this.mapViewMode,
    required this.mapViewChangeId,
  });

  RideSearchState copyWith({
    String? pickupText,
    String? dropText,
    bool? isPickupActive,
    bool? loading,
    List<PlaceSuggestion>? suggestions,
    double? pickupLat,
    double? pickupLng,
    double? dropLat,
    double? dropLng,
    String? message,
    bool? needsLocationPermission,
    int? locationPromptId,
    bool? pendingLocationRetry,
    MapViewMode? mapViewMode,
    int? mapViewChangeId,
  }) {
    return RideSearchState(
      pickupText: pickupText ?? this.pickupText,
      dropText: dropText ?? this.dropText,
      isPickupActive: isPickupActive ?? this.isPickupActive,
      loading: loading ?? this.loading,
      suggestions: suggestions ?? this.suggestions,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      dropLat: dropLat ?? this.dropLat,
      dropLng: dropLng ?? this.dropLng,
      message: message,
      needsLocationPermission:
          needsLocationPermission ?? this.needsLocationPermission,
      locationPromptId: locationPromptId ?? this.locationPromptId,
      pendingLocationRetry: pendingLocationRetry ?? this.pendingLocationRetry,
      mapViewMode: mapViewMode ?? this.mapViewMode,
      mapViewChangeId: mapViewChangeId ?? this.mapViewChangeId,
    );
  }

  factory RideSearchState.initial() {
    return const RideSearchState(
      pickupText: '',
      dropText: '',
      isPickupActive: true,
      loading: false,
      suggestions: [],
      pickupLat: null,
      pickupLng: null,
      dropLat: null,
      dropLng: null,
      needsLocationPermission: false,
      locationPromptId: 0,
      pendingLocationRetry: false,
      mapViewMode: MapViewMode.pickup,
      mapViewChangeId: 0,
    );
  }

  bool get canContinue {
    return pickupLat != null &&
        pickupLng != null &&
        dropLat != null &&
        dropLng != null;
  }

  bool get shouldAnimateVehicles {
    return mapViewMode == MapViewMode.both &&
        pickupLat != null &&
        pickupLng != null;
  }
}
