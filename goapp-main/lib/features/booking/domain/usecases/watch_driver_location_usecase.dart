import '../entities/geo_point.dart';
import '../repositories/driver_tracking_repository.dart';

class WatchDriverLocationUseCase {
  const WatchDriverLocationUseCase(this.repository);

  final DriverTrackingRepository repository;

  Stream<GeoPoint> call({required String rideId}) {
    return repository.trackDriver(rideId: rideId);
  }

  Future<void> disconnect() {
    return repository.disconnect();
  }
}
