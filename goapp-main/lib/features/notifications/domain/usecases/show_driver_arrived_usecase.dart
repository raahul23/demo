import '../repositories/notification_repository.dart';

class ShowDriverArrivedUseCase {
  final NotificationRepository repository;

  const ShowDriverArrivedUseCase(this.repository);

  Future<void> call() => repository.showDriverArrived();
}
