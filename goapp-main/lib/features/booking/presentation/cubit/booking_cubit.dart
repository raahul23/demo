import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/geo_point.dart';
import '../../domain/entities/booking_service.dart';
import '../../domain/services/fare_calculator.dart';
import '../../domain/entities/fare_quote.dart';
import '../../domain/usecases/get_booking_route_usecase.dart';
import '../../domain/usecases/book_ride_usecase.dart';
import '../../domain/usecases/watch_driver_location_usecase.dart';
import 'booking_state.dart';
import '../../../../core/maps/map_view_mode.dart';
import '../../domain/entities/driver_search_status.dart';
import '../../domain/entities/driver_info.dart';
import '../../domain/usecases/get_driver_info_usecase.dart';
import '../../domain/services/driver_arrival_estimator.dart';
import '../../domain/services/driver_tracking_service.dart';
import 'package:flutter/foundation.dart';
import '../booking_flow_coordinator.dart';
import '../booking_progress_controller.dart';

class BookingCubit extends Cubit<BookingState> {
  final GetBookingRouteUseCase getBookingRouteUseCase;
  final FareCalculator fareCalculator;
  final GetDriverInfoUseCase getDriverInfoUseCase;
  final DriverArrivalEstimator driverArrivalEstimator;
  final DriverTrackingService driverTrackingService;
  final BookingProgressController? progressController;
  final BookingFlowCoordinator? flowCoordinator;
  final bool enableSideEffects;

  /// Optional — wires real ride booking to backend
  final BookRideUseCase? bookRideUseCase;

  /// Optional — wires real Socket.IO driver location stream
  final WatchDriverLocationUseCase? watchDriverLocationUseCase;

  Timer? _driverSearchTimer;
  StreamSubscription<DriverTrackingSample>? _driverTrackingSub;
  StreamSubscription<GeoPoint>? _socketTrackingSub;
  StreamSubscription<BookingState>? _sideEffectSub;
  bool _rideAutoStarted = false;
  bool _rideCompleted = false;

  BookingCubit(
    this.getBookingRouteUseCase, {
    required this.fareCalculator,
    required this.getDriverInfoUseCase,
    required this.driverArrivalEstimator,
    required this.driverTrackingService,
    required GeoPoint pickup,
    required GeoPoint drop,
    required String pickupLabel,
    required String dropLabel,
    BookingService? initialService,
    bool autoLoad = true,
    bool autoRestore = false,
    this.progressController,
    this.flowCoordinator,
    this.enableSideEffects = true,
    this.bookRideUseCase,
    this.watchDriverLocationUseCase,
  }) : super(
          BookingState.initial(
            pickup: pickup,
            drop: drop,
            pickupLabel: pickupLabel,
            dropLabel: dropLabel,
          ).copyWith(selectedService: initialService),
        ) {
    if (autoLoad) {
      loadRoute();
    }
    if (enableSideEffects) {
      _sideEffectSub = stream.listen((s) {
        if (progressController != null) {
          unawaited(progressController!.persist(s));
        }
        if (flowCoordinator != null) {
          unawaited(flowCoordinator!.handleState(s));
        }
      });
    }
    if (autoRestore) {
      unawaited(_restoreProgressIfAny());
    }
  }

  Future<void> loadRoute() async {
    emit(state.copyWith(loading: true, errorMessage: null));
    try {
      final route = await getBookingRouteUseCase(
        pickup: state.pickup,
        drop: state.drop,
      );
      final distanceKm = route.distanceMeters / 1000;
      final durationMin = (route.durationSeconds / 60).round();
      final quote = fareCalculator.calculate(
        distanceMeters: route.distanceMeters,
        durationSeconds: route.durationSeconds,
      );
      emit(
        state.copyWith(
          loading: false,
          route: route,
          fareQuote: quote,
          selectedFare: _resolveFare(quote, state.selectedService),
          distanceKm: distanceKm,
          durationMin: durationMin,
          mapViewMode: MapViewMode.both,
          mapViewChangeId: state.mapViewChangeId + 1,
        ),
      );
    } catch (_) {
      emit(state.copyWith(loading: false, errorMessage: 'Failed to load route'));
    }
  }

  void toggleService(BookingService service) {
    final current = state.selectedService;
    final nextService = current == service ? null : service;
    final nextFare = _resolveFare(state.fareQuote, nextService);
    emit(
      state.copyWith(
        selectedService: nextService,
        resetSelectedService: current == service,
        selectedFare: nextFare,
        resetSelectedFare: current == service,
      ),
    );
  }

  void toggleMapView() {
    final next = state.mapViewMode == MapViewMode.both
        ? MapViewMode.pickup
        : MapViewMode.both;
    emit(state.copyWith(
      mapViewMode: next,
      mapViewChangeId: state.mapViewChangeId + 1,
    ));
  }

  void startDriverSearch({Duration delay = const Duration(seconds: 10)}) {
    _driverSearchTimer?.cancel();
    _driverTrackingSub?.cancel();
    _socketTrackingSub?.cancel();

    emit(
      state.copyWith(
        driverSearchStatus: DriverSearchStatus.searching,
        resetDriverArrival: true,
        resetDriverLocation: true,
        driverInfo: null,
        driverHasArrived: false,
        driverRoutePath: const [],
      ),
    );
    _rideAutoStarted = false;
    _rideCompleted = false;

    if (bookRideUseCase != null && state.selectedService != null) {
      _bookAndSearch(delay: delay);
    } else {
      _driverSearchTimer = Timer(delay, () {
        emit(state.copyWith(driverSearchStatus: DriverSearchStatus.found));
      });
    }
  }

  Future<void> _bookAndSearch({required Duration delay}) async {
    try {
      final route = state.route;
      final rideId = await bookRideUseCase!.call(
        vehicleType: state.selectedService!,
        pickup: state.pickup,
        pickupAddress: state.pickupLabel,
        drop: state.drop,
        dropAddress: state.dropLabel,
        encodedPolyline: route?.encodedPolyline ?? '',
        distanceMeters: ((state.distanceKm ?? 0) * 1000).round(),
        durationSeconds: (state.durationMin ?? 0) * 60,
      );
      emit(state.copyWith(rideId: rideId));
    } catch (_) {
      // Non-fatal — continue with simulation
    }

    // Wait for driver match (Phase 3 will replace with WebSocket event)
    _driverSearchTimer = Timer(delay, () {
      if (!isClosed) {
        emit(state.copyWith(driverSearchStatus: DriverSearchStatus.found));
      }
    });
  }

  void cancelDriverSearch() {
    _driverSearchTimer?.cancel();
    _driverTrackingSub?.cancel();
    _socketTrackingSub?.cancel();
    emit(
      state.copyWith(
        driverSearchStatus: DriverSearchStatus.idle,
        resetDriverArrival: true,
        resetDriverLocation: true,
        driverInfo: null,
        driverHasArrived: false,
        driverRoutePath: const [],
        clearRideId: true,
      ),
    );
    _rideAutoStarted = false;
    _rideCompleted = false;
  }

  Future<void> markDriverArriving() async {
    await _prepareArrival();
  }

  void cancelRide() {
    _driverSearchTimer?.cancel();
    _driverTrackingSub?.cancel();
    _socketTrackingSub?.cancel();
    emit(
      state.copyWith(
        driverSearchStatus: DriverSearchStatus.idle,
        resetDriverArrival: true,
        resetDriverLocation: true,
        driverInfo: null,
        driverHasArrived: false,
        driverRoutePath: const [],
        clearRideId: true,
      ),
    );
    _rideAutoStarted = false;
    _rideCompleted = false;
  }

  Future<void> restoreFromProgress({
    required DriverSearchStatus status,
    int? etaMin,
    double? distanceKm,
    DriverInfo? driver,
    BookingService? service,
    bool hasArrived = false,
  }) async {
    final resolvedDriver =
        driver ??
        await getDriverInfoUseCase(
          service: service ?? BookingService.bike,
          rideId: state.rideId,
        );
    final resolvedService = service ?? state.selectedService;
    final resolvedFare = _resolveFare(state.fareQuote, resolvedService);
    emit(
      state.copyWith(
        driverSearchStatus: status,
        driverInfo: resolvedDriver,
        driverArrivalMin: etaMin ?? state.driverArrivalMin,
        driverArrivalKm: distanceKm ?? state.driverArrivalKm,
        driverArrivalInitialMin: etaMin ?? state.driverArrivalInitialMin,
        driverHasArrived: hasArrived,
        selectedService: resolvedService,
        selectedFare: resolvedFare ?? state.selectedFare,
      ),
    );
  }

  Future<void> _restoreProgressIfAny() async {
    if (progressController == null) return;
    final restore = await progressController!.restore(
      pickup: state.pickup,
      drop: state.drop,
      pickupLabel: state.pickupLabel,
      dropLabel: state.dropLabel,
    );
    if (restore == null) return;
    await restoreFromProgress(
      status: restore.status,
      etaMin: restore.etaMin,
      distanceKm: restore.distanceKm,
      driver: restore.driver,
      service: restore.service,
      hasArrived: restore.hasArrived,
    );
  }

  Future<void> debugSetState(
    DriverSearchStatus status, {
    int? etaMin,
    double? distanceKm,
    DriverInfo? driver,
    bool hasArrived = false,
  }) async {
    if (!kDebugMode) return;
    if (status == DriverSearchStatus.idle) {
      emit(
        state.copyWith(
          driverSearchStatus: DriverSearchStatus.idle,
          resetDriverArrival: true,
          resetDriverLocation: true,
          driverInfo: null,
          driverHasArrived: false,
          driverRoutePath: const [],
        ),
      );
      return;
    }
    final resolvedDriver =
        driver ?? await getDriverInfoUseCase(service: BookingService.bike);
    emit(
      state.copyWith(
        driverSearchStatus: status,
        driverInfo: resolvedDriver,
        driverArrivalMin: etaMin ?? state.driverArrivalMin,
        driverArrivalKm: distanceKm ?? state.driverArrivalKm,
        driverArrivalInitialMin: etaMin ?? state.driverArrivalInitialMin,
        driverHasArrived: hasArrived,
      ),
    );
  }

  Future<void> _prepareArrival() async {
    final service = state.selectedService ?? BookingService.bike;
    final DriverInfo driver = await getDriverInfoUseCase(
      service: service,
      rideId: state.rideId,
    );
    final estimate = driverArrivalEstimator.estimate(
      tripDistanceKm: state.distanceKm,
      tripDurationMin: state.durationMin,
    );
    emit(
      state.copyWith(
        driverSearchStatus: DriverSearchStatus.arriving,
        driverArrivalKm: estimate.distanceKm,
        driverArrivalMin: estimate.etaMin,
        driverArrivalInitialMin: estimate.etaMin,
        driverInfo: driver,
        driverHasArrived: false,
        driverRoutePath: const [],
      ),
    );
    _startDriverTracking(
      pickup: state.pickup,
      initialDistanceKm: estimate.distanceKm,
      initialEtaMin: estimate.etaMin,
    );
  }

  void confirmOtpAndStartRide() {
    if (state.driverSearchStatus != DriverSearchStatus.arriving) return;
    _driverTrackingSub?.cancel();
    _socketTrackingSub?.cancel();
    emit(state.copyWith(driverSearchStatus: DriverSearchStatus.inRide));
    _startRideTracking();
  }

  void _startDriverTracking({
    required GeoPoint pickup,
    required double initialDistanceKm,
    required int initialEtaMin,
  }) {
    _driverTrackingSub?.cancel();
    _socketTrackingSub?.cancel();

    // Start real Socket.IO location stream if we have a rideId
    if (state.rideId != null && watchDriverLocationUseCase != null) {
      _socketTrackingSub = watchDriverLocationUseCase!
          .call(rideId: state.rideId!)
          .listen(
            (location) {
              if (!isClosed) emit(state.copyWith(driverLocation: location));
            },
            onError: (_) {}, // Silently fail — simulation continues
          );
    }

    // Always run simulation for ETA/path calculation
    _driverTrackingSub = driverTrackingService
        .trackToPickup(
          pickup: pickup,
          encodedPath: state.route?.encodedPolyline,
        )
        .listen((sample) {
      final remainingDistance = (1 - sample.progress) * initialDistanceKm;
      final remainingEta = (1 - sample.progress) * initialEtaMin;
      final hasArrived = sample.progress >= 1;

      emit(
        state.copyWith(
          // Only update location from simulation if no real socket stream
          driverLocation: state.rideId == null ? sample.location : null,
          driverArrivalKm: remainingDistance < 0 ? 0 : remainingDistance,
          driverArrivalMin: remainingEta < 1 ? 1 : remainingEta.round(),
          driverHasArrived: hasArrived,
          driverRoutePath: sample.remainingPath,
        ),
      );
      if (hasArrived &&
          state.driverSearchStatus == DriverSearchStatus.arriving &&
          !_rideAutoStarted) {
        _rideAutoStarted = true;
        _socketTrackingSub?.cancel();
        _startRideTracking();
      }
    });
  }

  void _startRideTracking() {
    _driverTrackingSub?.cancel();
    _socketTrackingSub?.cancel();

    final distanceKm = state.distanceKm ?? 0;
    final durationMin = state.durationMin ?? 0;

    emit(
      state.copyWith(
        driverSearchStatus: DriverSearchStatus.inRide,
        driverLocation: state.pickup,
        driverRoutePath: [state.pickup, state.drop],
        driverArrivalKm: distanceKm,
        driverArrivalMin: durationMin,
        mapViewMode: MapViewMode.both,
        mapViewChangeId: state.mapViewChangeId + 1,
      ),
    );

    // Start real socket location for in-ride tracking
    if (state.rideId != null && watchDriverLocationUseCase != null) {
      _socketTrackingSub = watchDriverLocationUseCase!
          .call(rideId: state.rideId!)
          .listen(
            (location) {
              if (!isClosed) emit(state.copyWith(driverLocation: location));
            },
            onError: (_) {},
          );
    }

    _driverTrackingSub = driverTrackingService
        .trackToDrop(
          pickup: state.pickup,
          drop: state.drop,
          encodedPath: state.route?.encodedPolyline,
        )
        .listen((sample) {
      final remainingDistance = (1 - sample.progress) * distanceKm;
      final remainingEta = (1 - sample.progress) * durationMin;
      emit(
        state.copyWith(
          driverLocation: state.rideId == null ? sample.location : null,
          driverArrivalKm: remainingDistance < 0 ? 0 : remainingDistance,
          driverArrivalMin: remainingEta < 1 ? 1 : remainingEta.round(),
          driverRoutePath: sample.remainingPath,
        ),
      );
      if (sample.progress >= 1 &&
          state.driverSearchStatus == DriverSearchStatus.inRide &&
          !_rideCompleted) {
        _rideCompleted = true;
        emit(
          state.copyWith(
            driverSearchStatus: DriverSearchStatus.completed,
            driverArrivalKm: 0,
            driverArrivalMin: 0,
            driverRoutePath: const [],
          ),
        );
      }
    });
  }

  double? _resolveFare(FareQuote? quote, BookingService? service) {
    if (quote == null || service == null) return null;
    return quote.servicePrices[service] ?? quote.baseFare;
  }

  @override
  Future<void> close() {
    _driverSearchTimer?.cancel();
    _driverTrackingSub?.cancel();
    _socketTrackingSub?.cancel();
    _sideEffectSub?.cancel();
    watchDriverLocationUseCase?.disconnect().ignore();
    unawaited(flowCoordinator?.dispose());
    return super.close();
  }

  Future<void> handleLifecycle(AppLifecycleState appState) async {
    if (!enableSideEffects || flowCoordinator == null) return;
    await flowCoordinator!.handleLifecycle(appState);
  }
}
