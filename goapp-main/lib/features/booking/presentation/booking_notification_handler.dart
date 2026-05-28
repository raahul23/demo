import '../../notifications/domain/entities/notification_progress.dart';
import '../../notifications/presentation/cubit/notifications_cubit.dart';
import '../domain/entities/driver_search_status.dart';
import 'cubit/booking_state.dart';

class BookingNotificationHandler {
  final NotificationsCubit notificationsCubit;
  BookingState? _previous;

  BookingNotificationHandler({required this.notificationsCubit});

  void handle(BookingState current) {
    final previous = _previous;
    _previous = current;
    if (previous == null) return;

    _handleStatusChange(previous, current);
    _handleArrivalProgress(previous, current);
    _handleRideProgress(previous, current);
  }

  void _handleStatusChange(BookingState previous, BookingState current) {
    if (previous.driverSearchStatus != current.driverSearchStatus) {
      if (current.driverSearchStatus == DriverSearchStatus.arriving) {
        final driver = current.driverInfo;
        final progress = _arrivingProgress(current);
        if (driver != null && progress != null) {
          notificationsCubit.driverAccepted(
            driverName: driver.name,
            vehicle: '${driver.vehicleModel} • ${driver.plateNumber}',
            progress: progress,
          );
        }
      }
      if (current.driverSearchStatus == DriverSearchStatus.inRide) {
        notificationsCubit.rideStarted(dropLabel: current.dropLabel);
      }
      if (current.driverSearchStatus == DriverSearchStatus.completed) {
        notificationsCubit.rideCompleted(dropLabel: current.dropLabel);
      }
    }

    if (!previous.driverHasArrived && current.driverHasArrived) {
      notificationsCubit.driverArrived();
    }
  }

  void _handleArrivalProgress(BookingState previous, BookingState current) {
    if (current.driverSearchStatus != DriverSearchStatus.arriving) return;
    if (previous.driverArrivalMin == current.driverArrivalMin &&
        previous.driverArrivalKm == current.driverArrivalKm) {
      return;
    }
    final progress = _arrivingProgress(current);
    if (progress == null) return;
    notificationsCubit.driverArriving(progress: progress);
  }

  void _handleRideProgress(BookingState previous, BookingState current) {
    if (current.driverSearchStatus != DriverSearchStatus.inRide) return;
    if (previous.driverArrivalMin == current.driverArrivalMin &&
        previous.driverArrivalKm == current.driverArrivalKm) {
      return;
    }
    final progress = _rideProgress(current);
    if (progress == null) return;
    notificationsCubit.rideProgress(progress: progress);
  }

  NotificationProgress? _arrivingProgress(BookingState state) {
    final etaMin = state.driverArrivalMin;
    final initialMin = state.driverArrivalInitialMin ?? etaMin;
    final distanceKm = state.driverArrivalKm;
    if (etaMin == null || initialMin == null || distanceKm == null) return null;
    final percent = _progressPercent(
      initialMin: initialMin,
      remainingMin: etaMin,
      remainingKm: distanceKm,
    );
    return NotificationProgress(
      percent: percent,
      etaMin: etaMin,
      distanceKm: distanceKm,
    );
  }

  NotificationProgress? _rideProgress(BookingState state) {
    final etaMin = state.driverArrivalMin;
    final initialMin = state.durationMin ?? etaMin;
    final distanceKm = state.driverArrivalKm;
    if (etaMin == null || initialMin == null || distanceKm == null) return null;
    final percent = _progressPercent(
      initialMin: initialMin,
      remainingMin: etaMin,
      remainingKm: distanceKm,
    );
    return NotificationProgress(
      percent: percent,
      etaMin: etaMin,
      distanceKm: distanceKm,
    );
  }

  int _progressPercent({
    required int initialMin,
    required int remainingMin,
    required double remainingKm,
  }) {
    if (initialMin <= 0) return 0;
    if (remainingMin <= 1 || remainingKm <= 0.05) {
      return 100;
    }
    final fraction = 1 - (remainingMin / initialMin);
    final percent = (fraction * 100).round();
    if (percent < 0) return 0;
    if (percent > 100) return 100;
    return percent;
  }
}
