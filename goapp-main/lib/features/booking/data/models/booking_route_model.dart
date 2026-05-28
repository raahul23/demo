import '../../domain/entities/booking_route.dart';

class BookingRouteModel extends BookingRoute {
  const BookingRouteModel({
    required super.encodedPolyline,
    required super.distanceMeters,
    required super.durationSeconds,
  });
}
