import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/notification_progress.dart';
import '../../domain/usecases/init_notifications_usecase.dart';
import '../../domain/usecases/show_driver_accepted_usecase.dart';
import '../../domain/usecases/show_driver_arrived_usecase.dart';
import '../../domain/usecases/show_driver_arriving_usecase.dart';
import '../../domain/usecases/show_ride_completed_usecase.dart';
import '../../domain/usecases/show_ride_progress_usecase.dart';
import '../../domain/usecases/show_ride_started_usecase.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final InitNotificationsUseCase initNotificationsUseCase;
  final ShowDriverAcceptedUseCase showDriverAcceptedUseCase;
  final ShowDriverArrivingUseCase showDriverArrivingUseCase;
  final ShowDriverArrivedUseCase showDriverArrivedUseCase;
  final ShowRideStartedUseCase showRideStartedUseCase;
  final ShowRideProgressUseCase showRideProgressUseCase;
  final ShowRideCompletedUseCase showRideCompletedUseCase;
  final Duration minUpdateInterval;
  final int minPercentStep;

  bool _initializing = false;
  DateTime? _lastArrivingUpdateAt;
  DateTime? _lastRideUpdateAt;

  NotificationsCubit({
    required this.initNotificationsUseCase,
    required this.showDriverAcceptedUseCase,
    required this.showDriverArrivingUseCase,
    required this.showDriverArrivedUseCase,
    required this.showRideStartedUseCase,
    required this.showRideProgressUseCase,
    required this.showRideCompletedUseCase,
    this.minUpdateInterval = const Duration(seconds: 3),
    this.minPercentStep = 3,
  }) : super(NotificationsState.initial());

  Future<void> init() async {
    if (state.initialized || _initializing) return;
    _initializing = true;
    await initNotificationsUseCase();
    _initializing = false;
    emit(state.copyWith(initialized: true));
  }

  Future<void> driverAccepted({
    required String driverName,
    required String vehicle,
    required NotificationProgress progress,
  }) async {
    await _ensureInit();
    await showDriverAcceptedUseCase(
      driverName: driverName,
      vehicle: vehicle,
      progress: progress,
    );
    emit(state.copyWith(resetArrivingPercent: true));
  }

  Future<void> driverArriving({
    required NotificationProgress progress,
  }) async {
    if (!_shouldUpdate(progress, state.lastArrivingPercent, _lastArrivingUpdateAt)) {
      return;
    }
    await _ensureInit();
    _lastArrivingUpdateAt = DateTime.now();
    emit(state.copyWith(lastArrivingPercent: progress.percent));
    await showDriverArrivingUseCase(progress: progress);
  }

  Future<void> driverArrived() async {
    await _ensureInit();
    emit(state.copyWith(lastArrivingPercent: 100));
    await showDriverArrivedUseCase();
  }

  Future<void> rideStarted({
    required String dropLabel,
  }) async {
    await _ensureInit();
    emit(state.copyWith(resetRidePercent: true));
    await showRideStartedUseCase(dropLabel: dropLabel);
  }

  Future<void> rideProgress({
    required NotificationProgress progress,
  }) async {
    if (!_shouldUpdate(progress, state.lastRidePercent, _lastRideUpdateAt)) {
      return;
    }
    await _ensureInit();
    _lastRideUpdateAt = DateTime.now();
    emit(state.copyWith(lastRidePercent: progress.percent));
    await showRideProgressUseCase(progress: progress);
  }

  Future<void> rideCompleted({required String dropLabel}) async {
    await _ensureInit();
    await showRideCompletedUseCase(dropLabel: dropLabel);
  }

  Future<void> _ensureInit() async {
    if (!state.initialized) {
      await init();
    }
  }

  bool _shouldUpdate(
    NotificationProgress progress,
    int? lastPercent,
    DateTime? lastUpdatedAt,
  ) {
    if (lastPercent == null) return true;
    if ((progress.percent - lastPercent).abs() < minPercentStep) {
      final now = DateTime.now();
      if (lastUpdatedAt != null &&
          now.difference(lastUpdatedAt) < minUpdateInterval) {
        return false;
      }
    }
    return true;
  }
}
