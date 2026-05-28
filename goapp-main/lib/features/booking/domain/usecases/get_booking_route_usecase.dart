import '../entities/booking_route.dart';
import '../entities/geo_point.dart';
import '../repositories/booking_repository.dart';

class GetBookingRouteUseCase {
  final BookingRepository repository;

  GetBookingRouteUseCase(this.repository);

  Future<BookingRoute> call({
    required GeoPoint pickup,
    required GeoPoint drop,
  }) {
    return repository.fetchRoute(pickup: pickup, drop: drop);
  }
}
