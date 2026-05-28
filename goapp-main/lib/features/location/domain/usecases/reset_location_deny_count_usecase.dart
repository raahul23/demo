import '../repositories/location_permission_repository.dart';

class ResetLocationDenyCountUseCase {
  final LocationPermissionRepository repository;

  ResetLocationDenyCountUseCase(this.repository);

  Future<void> call() => repository.resetDenyCount();
}
