import '../entities/geo_point.dart';

abstract class DriverTrackingRepository {
  Stream<GeoPoint> trackDriver({required String rideId});
  Future<void> disconnect();
}
