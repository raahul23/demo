import '../../domain/entities/notification_progress.dart';

abstract class NotificationsLocalDataSource {
  Future<void> init();

  Future<void> showDriverAccepted({
    required String driverName,
    required String vehicle,
    required NotificationProgress progress,
  });

  Future<void> showDriverArriving({
    required NotificationProgress progress,
  });

  Future<void> showDriverArrived();

  Future<void> showRideStarted({
    required String dropLabel,
  });

  Future<void> showRideProgress({
    required NotificationProgress progress,
  });

  Future<void> showRideCompleted({
    required String dropLabel,
  });
}
