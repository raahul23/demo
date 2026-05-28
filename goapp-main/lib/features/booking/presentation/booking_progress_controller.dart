import '../domain/entities/booking_progress.dart';
import '../domain/entities/booking_progress_state.dart';
import '../domain/entities/booking_service.dart';
import '../domain/entities/driver_info.dart';
import '../domain/entities/driver_search_status.dart';
import '../domain/entities/geo_point.dart';
import '../domain/usecases/clear_booking_progress_usecase.dart';
import '../domain/usecases/get_booking_progress_usecase.dart';
import '../domain/usecases/save_booking_progress_usecase.dart';
import 'cubit/booking_state.dart';

class BookingProgressRestore {
  final DriverSearchStatus status;
  final int? etaMin;
  final double? distanceKm;
  final DriverInfo? driver;
  final BookingService? service;
  final bool hasArrived;

  const BookingProgressRestore({
    required this.status,
    this.etaMin,
    this.distanceKm,
    this.driver,
    this.service,
    required this.hasArrived,
  });
}

class BookingProgressController {
  final GetBookingProgressUseCase getProgress;
  final SaveBookingProgressUseCase saveProgress;
  final ClearBookingProgressUseCase clearProgress;
  static const Duration _minPersistInterval = Duration(seconds: 3);
  String? _lastPersistKey;
  DateTime? _lastPersistAt;

  BookingProgressController({
    required this.getProgress,
    required this.saveProgress,
    required this.clearProgress,
  });

  Future<void> persist(BookingState state) async {
    if (_isIdleOrCompleted(state.driverSearchStatus)) {
      await clearProgress();
      _lastPersistKey = null;
      _lastPersistAt = null;
      return;
    }
    final progress = BookingProgress(
      state: _mapStateToProgress(state),
      etaMin: state.driverArrivalMin,
      distanceKm: state.driverArrivalKm,
      driver: state.driverInfo,
      sessionKey: buildSessionKey(
        pickup: state.pickup,
        drop: state.drop,
        pickupLabel: state.pickupLabel,
        dropLabel: state.dropLabel,
      ),
      service: state.selectedService ?? state.driverInfo?.service,
    );
    final persistKey = _persistKeyFor(progress);
    if (_shouldSkipPersist(persistKey)) {
      return;
    }
    _lastPersistKey = persistKey;
    _lastPersistAt = DateTime.now();
    await saveProgress(progress);
  }

  Future<BookingProgressRestore?> restore({
    required GeoPoint pickup,
    required GeoPoint drop,
    required String pickupLabel,
    required String dropLabel,
  }) async {
    final progress = getProgress();
    if (progress == null) return null;
    final currentSession = buildSessionKey(
      pickup: pickup,
      drop: drop,
      pickupLabel: pickupLabel,
      dropLabel: dropLabel,
    );
    if (_hasMismatchedSession(progress, currentSession)) {
      await clearProgress();
      return null;
    }
    if (_isTerminal(progress.state)) {
      await clearProgress();
      return null;
    }
    return BookingProgressRestore(
      status: _mapProgressState(progress.state),
      etaMin: progress.etaMin,
      distanceKm: progress.distanceKm,
      driver: progress.driver,
      service: progress.service,
      hasArrived: progress.state == BookingProgressState.driverArrived,
    );
  }

  String buildSessionKey({
    required GeoPoint pickup,
    required GeoPoint drop,
    required String pickupLabel,
    required String dropLabel,
  }) {
    return '${pickup.lat},${pickup.lng}|${drop.lat},${drop.lng}|$pickupLabel|$dropLabel';
  }

  bool _isIdleOrCompleted(DriverSearchStatus status) {
    return status == DriverSearchStatus.idle ||
        status == DriverSearchStatus.completed;
  }

  bool _hasMismatchedSession(BookingProgress progress, String currentSession) {
    final sessionKey = progress.sessionKey;
    return sessionKey != null &&
        sessionKey.isNotEmpty &&
        sessionKey != currentSession;
  }

  bool _isTerminal(BookingProgressState state) {
    return state == BookingProgressState.reachedDropLocation ||
        state == BookingProgressState.rideCompleted ||
        state == BookingProgressState.cancelled;
  }

  String _persistKeyFor(BookingProgress progress) {
    final eta = progress.etaMin?.toString() ?? '';
    final distance = progress.distanceKm?.toStringAsFixed(2) ?? '';
    final driver = progress.driver;
    final driverKey = driver == null
        ? ''
        : '${driver.name}|${driver.vehicleModel}|${driver.plateNumber}|${driver.phone}';
    final service = progress.service?.name ?? '';
    final session = progress.sessionKey ?? '';
    return '${bookingProgressStateToString(progress.state)}|$eta|$distance|$driverKey|$service|$session';
  }

  bool _shouldSkipPersist(String key) {
    if (_lastPersistKey != key) return false;
    final lastAt = _lastPersistAt;
    if (lastAt == null) return false;
    final elapsed = DateTime.now().difference(lastAt);
    return elapsed < _minPersistInterval;
  }

  BookingProgressState _mapStateToProgress(BookingState state) {
    switch (state.driverSearchStatus) {
      case DriverSearchStatus.searching:
        return BookingProgressState.searchingForDriver;
      case DriverSearchStatus.found:
        return BookingProgressState.driverAccepted;
      case DriverSearchStatus.arriving:
        return state.driverHasArrived
            ? BookingProgressState.driverArrived
            : BookingProgressState.driverArriving;
      case DriverSearchStatus.inRide:
        return BookingProgressState.rideStarted;
      case DriverSearchStatus.completed:
        return BookingProgressState.reachedDropLocation;
      case DriverSearchStatus.idle:
        return BookingProgressState.searchingForDriver;
    }
  }

  DriverSearchStatus _mapProgressState(BookingProgressState state) {
    switch (state) {
      case BookingProgressState.searchingForDriver:
        return DriverSearchStatus.searching;
      case BookingProgressState.driverAccepted:
        return DriverSearchStatus.found;
      case BookingProgressState.driverArriving:
      case BookingProgressState.driverArrived:
        return DriverSearchStatus.arriving;
      case BookingProgressState.rideStarted:
        return DriverSearchStatus.inRide;
      case BookingProgressState.reachedDropLocation:
      case BookingProgressState.rideCompleted:
      case BookingProgressState.cancelled:
        return DriverSearchStatus.completed;
    }
  }
}
