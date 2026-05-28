import '../../domain/repositories/location_permission_repository.dart';
import '../datasources/location_permission_storage.dart';

class LocationPermissionRepositoryImpl implements LocationPermissionRepository {
  final LocationPermissionStorage storage;

  LocationPermissionRepositoryImpl({required this.storage});

  @override
  Future<int> getDenyCount() => storage.getDenyCount();

  @override
  Future<void> incrementDenyCount() async {
    final current = await storage.getDenyCount();
    await storage.setDenyCount(current + 1);
  }

  @override
  Future<void> resetDenyCount() async {
    await storage.setDenyCount(0);
  }
}
