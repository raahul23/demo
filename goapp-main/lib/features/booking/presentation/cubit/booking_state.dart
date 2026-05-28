import '../../domain/entities/booking_route.dart';
import '../../domain/entities/geo_point.dart';
import '../../domain/entities/booking_service.dart';
import '../../domain/entities/fare_quote.dart';
import '../../../../core/maps/map_view_mode.dart';
import '../../domain/entities/driver_search_status.dart';
import '../../domain/entities/driver_info.dart';

class BookingState {
  final GeoPoint pickup;
  final GeoPoint drop;
  final String pickupLabel;
  final String dropLabel;
  final bool loading;
  final BookingRoute? route;
  final String? errorMessage;
  final BookingService? selectedService;
  final FareQuote? fareQuote;
  final double? selectedFare;
  final double? distanceKm;
  final int? durationMin;
  final MapViewMode mapViewMode;
  final int mapViewChangeId;
  final DriverSearchStatus driverSearchStatus;
  final double? driverArrivalKm;
  final int? driverArrivalMin;
  final int? driverArrivalInitialMin;
  final DriverInfo? driverInfo;
  final GeoPoint? driverLocation;
  final bool driverHasArrived;
  final List<GeoPoint> driverRoutePath;

  /// Backend ride ID — set after a successful POST /rides/book
  final String? rideId;

  const BookingState({
    required this.pickup,
    required this.drop,
    required this.pickupLabel,
    required this.dropLabel,
    required this.loading,
    required this.route,
    required this.errorMessage,
    required this.selectedService,
    required this.fareQuote,
    required this.selectedFare,
    required this.distanceKm,
    required this.durationMin,
    required this.mapViewMode,
    required this.mapViewChangeId,
    required this.driverSearchStatus,
    required this.driverArrivalKm,
    required this.driverArrivalMin,
    required this.driverArrivalInitialMin,
    required this.driverInfo,
    required this.driverLocation,
    required this.driverHasArrived,
    required this.driverRoutePath,
    this.rideId,
  });

  BookingState copyWith({
    bool? loading,
    BookingRoute? route,
    String? errorMessage,
    BookingService? selectedService,
    bool resetSelectedService = false,
    FareQuote? fareQuote,
    double? selectedFare,
    bool resetSelectedFare = false,
    double? distanceKm,
    int? durationMin,
    MapViewMode? mapViewMode,
    int? mapViewChangeId,
    DriverSearchStatus? driverSearchStatus,
    double? driverArrivalKm,
    int? driverArrivalMin,
    bool resetDriverArrival = false,
    int? driverArrivalInitialMin,
    DriverInfo? driverInfo,
    GeoPoint? driverLocation,
    bool resetDriverLocation = false,
    bool? driverHasArrived,
    List<GeoPoint>? driverRoutePath,
    String? rideId,
    bool clearRideId = false,
  }) {
    return BookingState(
      pickup: pickup,
      drop: drop,
      pickupLabel: pickupLabel,
      dropLabel: dropLabel,
      loading: loading ?? this.loading,
      route: route ?? this.route,
      errorMessage: errorMessage,
      selectedService:
          resetSelectedService ? null : (selectedService ?? this.selectedService),
      fareQuote: fareQuote ?? this.fareQuote,
      selectedFare:
          resetSelectedFare ? null : (selectedFare ?? this.selectedFare),
      distanceKm: distanceKm ?? this.distanceKm,
      durationMin: durationMin ?? this.durationMin,
      mapViewMode: mapViewMode ?? this.mapViewMode,
      mapViewChangeId: mapViewChangeId ?? this.mapViewChangeId,
      driverSearchStatus: driverSearchStatus ?? this.driverSearchStatus,
      driverArrivalKm:
          resetDriverArrival ? null : (driverArrivalKm ?? this.driverArrivalKm),
      driverArrivalMin: resetDriverArrival
          ? null
          : (driverArrivalMin ?? this.driverArrivalMin),
      driverArrivalInitialMin: resetDriverArrival
          ? null
          : (driverArrivalInitialMin ?? this.driverArrivalInitialMin),
      driverInfo: driverInfo ?? this.driverInfo,
      driverLocation: resetDriverLocation
          ? null
          : (driverLocation ?? this.driverLocation),
      driverHasArrived:
          resetDriverArrival ? false : (driverHasArrived ?? this.driverHasArrived),
      driverRoutePath: resetDriverArrival
          ? const []
          : (driverRoutePath ?? this.driverRoutePath),
      rideId: clearRideId ? null : (rideId ?? this.rideId),
    );
  }

  factory BookingState.initial({
    required GeoPoint pickup,
    required GeoPoint drop,
    required String pickupLabel,
    required String dropLabel,
  }) {
    return BookingState(
      pickup: pickup,
      drop: drop,
      pickupLabel: pickupLabel,
      dropLabel: dropLabel,
      loading: false,
      route: null,
      errorMessage: null,
      selectedService: null,
      fareQuote: null,
      selectedFare: null,
      distanceKm: null,
      durationMin: null,
      mapViewMode: MapViewMode.pickup,
      mapViewChangeId: 0,
      driverSearchStatus: DriverSearchStatus.idle,
      driverArrivalKm: null,
      driverArrivalMin: null,
      driverArrivalInitialMin: null,
      driverInfo: null,
      driverLocation: null,
      driverHasArrived: false,
      driverRoutePath: const [],
      rideId: null,
    );
  }
}
