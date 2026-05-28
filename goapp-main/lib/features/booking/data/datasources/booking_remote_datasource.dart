import '../models/booking_route_model.dart';
import '../../domain/entities/geo_point.dart';
import '../../domain/entities/booking_service.dart';

abstract class BookingRemoteDataSource {
  Future<BookingRouteModel> fetchRoute({
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
