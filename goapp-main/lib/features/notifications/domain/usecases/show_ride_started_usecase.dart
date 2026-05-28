import '../repositories/notification_repository.dart';

class ShowRideStartedUseCase {
  final NotificationRepository repository;

  const ShowRideStartedUseCase(this.repository);

  Future<void> call({required String dropLabel}) {
    return repository.showRideStarted(dropLabel: dropLabel);
  }
}
