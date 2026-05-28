import '../entities/ride_activity.dart';

abstract class ActivityRepository {
  Future<List<RideActivity>> getActivities();

  Future<bool> downloadReceipt(String rideId);
}
