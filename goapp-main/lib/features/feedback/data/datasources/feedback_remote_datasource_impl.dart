import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/feedback_submission.dart';
import 'feedback_remote_datasource.dart';

class FeedbackRemoteDataSourceImpl implements FeedbackRemoteDataSource {
  final ApiClient _apiClient;

  FeedbackRemoteDataSourceImpl(this._apiClient);

  @override
  Future<void> submit(FeedbackSubmission submission) async {
    try {
      await _apiClient.post(
        '/feedback',
        data: {
          'driver_name': submission.driverName,
          'vehicle': submission.vehicle,
          'plate_number': submission.plateNumber,
          'pickup_label': submission.pickupLabel,
          'drop_label': submission.dropLabel,
          'distance_km': submission.distanceKm,
          'duration_min': submission.durationMin,
          'rating': submission.rating,
          'comment': submission.comment,
        },
      );
    } on DioException {
      // Silently fail — feedback is non-critical
    }
  }
}
