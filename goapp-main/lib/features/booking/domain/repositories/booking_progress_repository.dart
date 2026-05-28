import '../entities/booking_progress.dart';

abstract class BookingProgressRepository {
  BookingProgress? get();
  Future<void> save(BookingProgress progress);
  Future<void> clear();
}
