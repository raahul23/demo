import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/ride_activity.dart';
import 'activity_remote_datasource.dart';

class ActivityRemoteDataSourceImpl implements ActivityRemoteDataSource {
  final ApiClient _apiClient;

  ActivityRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<RideActivity>> fetchActivities() async {
    try {
      final response = await _apiClient.get('/rides/history');
      final List<dynamic> data = response.data as List<dynamic>? ?? [];

      return data
          .map((json) => _fromJson(json as Map<String, dynamic>))
          .whereType<RideActivity>()
          .toList();
    } on DioException {
      return [];
    }
  }

  RideActivity? _fromJson(Map<String, dynamic> json) {
    try {
      final statusStr = json['status'] as String? ?? '';
      final RideActivityStatus status;
      if (statusStr == 'RIDE_COMPLETED') {
        status = RideActivityStatus.completed;
      } else if (statusStr == 'CANCELLED') {
        status = RideActivityStatus.cancelled;
      } else {
        return null; // Skip non-terminal rides
      }

      final cancelledByStr = json['cancelled_by'] as String?;
      RideCancelledBy? cancelledBy;
      if (cancelledByStr == 'RIDER') {
        cancelledBy = RideCancelledBy.rider;
      } else if (cancelledByStr == 'DRIVER') {
        cancelledBy = RideCancelledBy.driver;
      }

      final driverJson = json['driver'] as Map<String, dynamic>?;
      final paymentJson = json['payment'] as Map<String, dynamic>?;

      final startedAtStr = json['started_at'] as String?;
      final endedAtStr = json['ended_at'] as String?;
      final now = DateTime.now();

      return RideActivity(
        id: json['id'] as String,
        status: status,
        pickupLabel: json['pickup_label'] as String? ?? '',
        dropLabel: json['drop_label'] as String? ?? '',
        startedAt: startedAtStr != null ? DateTime.parse(startedAtStr) : now,
        endedAt: endedAtStr != null ? DateTime.parse(endedAtStr) : now,
        distanceKm: double.tryParse(json['distance_km']?.toString() ?? '0') ?? 0.0,
        durationMin: json['duration_min'] as int? ?? 0,
        cancelledBy: cancelledBy,
        driver: DriverSummary(
          name: driverJson?['name'] as String? ?? 'Driver',
          vehicle: driverJson?['vehicle'] as String? ?? 'Vehicle',
          plate: driverJson?['plate'] as String? ?? 'N/A',
          rating: (driverJson?['rating'] as num?)?.toDouble() ?? 5.0,
        ),
        payment: PaymentSummary(
          fare: (paymentJson?['fare'] as num?)?.toDouble() ?? 0.0,
          method: paymentJson?['method'] as String? ?? 'Cash',
          transactionId: paymentJson?['transaction_id'] as String? ?? '—',
        ),
        supportNote: json['support_note'] as String? ??
            'For help with this ride, reach support anytime.',
        receiptUrl: json['receipt_url'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> downloadReceipt(String rideId) async {
    try {
      await _apiClient.get('/rides/$rideId/receipt');
      return true;
    } on DioException {
      return false;
    }
  }
}
