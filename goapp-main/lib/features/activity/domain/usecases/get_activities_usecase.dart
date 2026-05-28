import '../entities/ride_activity.dart';
import '../repositories/activity_repository.dart';

class GetActivitiesUseCase {
  final ActivityRepository repository;

  GetActivitiesUseCase(this.repository);

  Future<List<RideActivity>> call() {
    return repository.getActivities();
  }
}
