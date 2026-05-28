import '../repositories/booking_progress_repository.dart';

class ClearBookingProgressUseCase {
  final BookingProgressRepository repository;

  ClearBookingProgressUseCase(this.repository);

  Future<void> call() => repository.clear();
}
