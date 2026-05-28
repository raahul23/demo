import '../repositories/notification_repository.dart';

class InitNotificationsUseCase {
  final NotificationRepository repository;

  const InitNotificationsUseCase(this.repository);

  Future<void> call() => repository.init();
}
