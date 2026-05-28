import '../entities/booking_service.dart';
import '../entities/driver_info.dart';
import '../repositories/driver_repository.dart';

class GetDriverInfoUseCase {
  final DriverRepository repository;

  GetDriverInfoUseCase(this.repository);

  Future<DriverInfo> call({
    required BookingService service,
    String? rideId,
  }) {
    return repository.fetchDriver(service: service, rideId: rideId);
  }
}
