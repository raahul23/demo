import '../../domain/entities/notification_progress.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notifications_local_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationsLocalDataSource localDataSource;

  const NotificationRepositoryImpl({required this.localDataSource});

  @override
  Future<void> init() => localDataSource.init();

  @override
  Future<void> showDriverAccepted({
    required String driverName,
    required String vehicle,
    required NotificationProgress progress,
  }) {
    return localDataSource.showDriverAccepted(
      driverName: driverName,
      vehicle: vehicle,
      progress: progress,
    );
  }

  @override
  Future<void> showDriverArriving({
    required NotificationProgress progress,
  }) {
    return localDataSource.showDriverArriving(progress: progress);
  }

  @override
  Future<void> showDriverArrived() {
    return localDataSource.showDriverArrived();
  }

  @override
  Future<void> showRideStarted({required String dropLabel}) {
    return localDataSource.showRideStarted(dropLabel: dropLabel);
  }

  @override
  Future<void> showRideProgress({required NotificationProgress progress}) {
    return localDataSource.showRideProgress(progress: progress);
  }

  @override
  Future<void> showRideCompleted({required String dropLabel}) {
    return localDataSource.showRideCompleted(dropLabel: dropLabel);
  }
}
