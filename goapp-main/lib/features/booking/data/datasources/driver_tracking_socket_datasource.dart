import '../../domain/entities/geo_point.dart';

abstract class DriverTrackingSocketDataSource {
  Stream<GeoPoint> connect({required String rideId});
  Future<void> disconnect();
}
