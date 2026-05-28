import '../entities/notification_progress.dart';
import '../repositories/notification_repository.dart';

class ShowRideProgressUseCase {
  final NotificationRepository repository;

  const ShowRideProgressUseCase(this.repository);

  Future<void> call({required NotificationProgress progress}) {
    return repository.showRideProgress(progress: progress);
  }
}
