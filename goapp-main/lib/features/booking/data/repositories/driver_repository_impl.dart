import '../../domain/entities/booking_service.dart';
import '../../domain/entities/driver_info.dart';
import '../../domain/repositories/driver_repository.dart';
import '../datasources/driver_remote_datasource.dart';

class DriverRepositoryImpl implements DriverRepository {
  final DriverRemoteDataSource remoteDataSource;

  DriverRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DriverInfo> fetchDriver({
    required BookingService service,
    String? rideId,
  }) {
    return remoteDataSource.fetchDriver(service: service, rideId: rideId);
  }
}
