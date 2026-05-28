import '../../domain/entities/geo_point.dart';
import '../../domain/repositories/driver_tracking_repository.dart';
import '../datasources/driver_tracking_socket_datasource.dart';

class DriverTrackingRepositoryImpl implements DriverTrackingRepository {
  DriverTrackingRepositoryImpl({
    required this.socketDataSource,
  });

  final DriverTrackingSocketDataSource socketDataSource;

  @override
  Stream<GeoPoint> trackDriver({required String rideId}) {
    return socketDataSource.connect(rideId: rideId);
  }

  @override
  Future<void> disconnect() {
    return socketDataSource.disconnect();
  }
}
