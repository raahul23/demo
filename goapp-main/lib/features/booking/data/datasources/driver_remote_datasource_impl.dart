import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/booking_service.dart';
import '../models/driver_info_model.dart';
import 'driver_remote_datasource.dart';

class DriverRemoteDataSourceImpl implements DriverRemoteDataSource {
  final ApiClient _apiClient;

  DriverRemoteDataSourceImpl(this._apiClient);

  @override
  Future<DriverInfoModel> fetchDriver({
    required BookingService service,
    String? rideId,
  }) async {
    if (rideId != null) {
      try {
        final response = await _apiClient.get('/rides/$rideId/driver');
        return DriverInfoModel.fromJson(
          response.data as Map<String, dynamic>,
          fallbackService: service,
        );
      } on DioException {
        // Fall through to mock
      }
    }
    return DriverInfoModel.mock(service);
  }
}
