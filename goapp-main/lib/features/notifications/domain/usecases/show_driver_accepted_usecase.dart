import '../entities/notification_progress.dart';
import '../repositories/notification_repository.dart';

class ShowDriverAcceptedUseCase {
  final NotificationRepository repository;

  const ShowDriverAcceptedUseCase(this.repository);

  Future<void> call({
    required String driverName,
    required String vehicle,
    required NotificationProgress progress,
  }) {
    return repository.showDriverAccepted(
      driverName: driverName,
      vehicle: vehicle,
      progress: progress,
    );
  }
}
