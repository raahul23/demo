import '../entities/booking_route.dart';
import '../entities/booking_service.dart';
import '../entities/geo_point.dart';

abstract class BookingRepository {
  Future<BookingRoute> fetchRoute({
    required GeoPoint pickup,
    required GeoPoint drop,
  });

  Future<String> bookRide({
    required BookingService vehicleType,
    required GeoPoint pickup,
    String? pickupAddress,
    required GeoPoint drop,
    String? dropAddress,
    required String encodedPolyline,
    required int distanceMeters,
    required int durationSeconds,
  });
}
