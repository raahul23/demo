import '../../domain/entities/booking_progress.dart';
import '../../domain/repositories/booking_progress_repository.dart';
import '../datasources/booking_progress_storage.dart';

class BookingProgressRepositoryImpl implements BookingProgressRepository {
  final BookingProgressStorage storage;

  BookingProgressRepositoryImpl({required this.storage});

  @override
  BookingProgress? get() => storage.get();

  @override
  Future<void> save(BookingProgress progress) => storage.save(progress);

  @override
  Future<void> clear() => storage.clear();
}
