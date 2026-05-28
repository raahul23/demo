import '../../domain/entities/ride_activity.dart';

abstract class ActivityRemoteDataSource {
  Future<List<RideActivity>> fetchActivities();

  Future<bool> downloadReceipt(String rideId);
}
