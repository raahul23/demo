import '../../domain/entities/ride_activity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../datasources/activity_remote_datasource.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityRemoteDataSource remoteDataSource;

  ActivityRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<RideActivity>> getActivities() {
    return remoteDataSource.fetchActivities();
  }

  @override
  Future<bool> downloadReceipt(String rideId) {
    return remoteDataSource.downloadReceipt(rideId);
  }
}
