import '../models/driver_info_model.dart';
import '../../domain/entities/booking_service.dart';

abstract class DriverRemoteDataSource {
  Future<DriverInfoModel> fetchDriver({
    required BookingService service,
    String? rideId,
  });
}
