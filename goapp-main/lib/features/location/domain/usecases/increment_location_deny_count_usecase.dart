import '../repositories/location_permission_repository.dart';

class IncrementLocationDenyCountUseCase {
  final LocationPermissionRepository repository;

  IncrementLocationDenyCountUseCase(this.repository);

  Future<void> call() => repository.incrementDenyCount();
}
