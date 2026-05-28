import '../entities/notification_progress.dart';
import '../repositories/notification_repository.dart';

class ShowDriverArrivingUseCase {
  final NotificationRepository repository;

  const ShowDriverArrivingUseCase(this.repository);

  Future<void> call({
    required NotificationProgress progress,
  }) {
    return repository.showDriverArriving(progress: progress);
  }
}
