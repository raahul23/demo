import '../entities/booking_progress.dart';
import '../repositories/booking_progress_repository.dart';

class GetBookingProgressUseCase {
  final BookingProgressRepository repository;

  GetBookingProgressUseCase(this.repository);

  BookingProgress? call() => repository.get();
}
