import '../entities/booking_progress.dart';
import '../repositories/booking_progress_repository.dart';

class SaveBookingProgressUseCase {
  final BookingProgressRepository repository;

  SaveBookingProgressUseCase(this.repository);

  Future<void> call(BookingProgress progress) {
    return repository.save(progress);
  }
}
