import '../entities/booking_service.dart';
import '../entities/geo_point.dart';
import '../repositories/booking_repository.dart';

class BookRideUseCase {
  final BookingRepository repository;

  const BookRideUseCase(this.repository);

  Future<String> call({
    required BookingService vehicleType,
    required GeoPoint pickup,
    String? pickupAddress,
    required GeoPoint drop,
    String? dropAddress,
    required String encodedPolyline,
    required int distanceMeters,
    required int durationSeconds,
  }) {
    return repository.bookRide(
      vehicleType: vehicleType,
      pickup: pickup,
      pickupAddress: pickupAddress,
      drop: drop,
      dropAddress: dropAddress,
      encodedPolyline: encodedPolyline,
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
    );
  }
}
