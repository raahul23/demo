import '../entities/booking_service.dart';
import '../entities/driver_info.dart';

abstract class DriverRepository {
  Future<DriverInfo> fetchDriver({
    required BookingService service,
    String? rideId,
  });
}
