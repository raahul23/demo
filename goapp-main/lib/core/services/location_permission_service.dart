enum LocationPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
}

abstract class LocationPermissionService {
  Future<LocationPermissionStatus> requestWhenInUse();
  Future<bool> openSettings();
}
