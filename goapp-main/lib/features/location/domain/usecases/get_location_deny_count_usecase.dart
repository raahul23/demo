import '../repositories/location_permission_repository.dart';

class GetLocationDenyCountUseCase {
  final LocationPermissionRepository repository;

  GetLocationDenyCountUseCase(this.repository);

  Future<int> call() => repository.getDenyCount();
}
