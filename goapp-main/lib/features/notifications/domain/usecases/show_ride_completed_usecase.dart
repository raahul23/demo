import '../repositories/notification_repository.dart';

class ShowRideCompletedUseCase {
  final NotificationRepository repository;

  const ShowRideCompletedUseCase(this.repository);

  Future<void> call({required String dropLabel}) {
    return repository.showRideCompleted(dropLabel: dropLabel);
  }
}
