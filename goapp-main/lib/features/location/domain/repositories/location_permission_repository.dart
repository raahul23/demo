abstract class LocationPermissionRepository {
  Future<int> getDenyCount();
  Future<void> incrementDenyCount();
  Future<void> resetDenyCount();
}
