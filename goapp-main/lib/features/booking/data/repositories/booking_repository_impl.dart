import '../../domain/entities/booking_route.dart';
import '../../domain/entities/booking_service.dart';
import '../../domain/entities/geo_point.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<BookingRoute> fetchRoute({
    required GeoPoint pickup,
    required GeoPoint drop,
  }) {
    return remoteDataSource.fetchRoute(pickup: pickup, drop: drop);
  }

  @override
  Future<String> bookRide({
    required BookingService vehicleType,
    required GeoPoint pickup,
    String? pickupAddress,
    required GeoPoint drop,
    String? dropAddress,
    required String encodedPolyline,
    required int distanceMeters,
    required int durationSeconds,
  }) {
    return remoteDataSource.bookRide(
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
