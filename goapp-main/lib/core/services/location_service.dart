import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<bool> canUseCurrentLocation() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return false;
    final permission = await Geolocator.checkPermission();
    return permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;
  }

  Future<Position?> getCurrentPosition() async {
    final canUse = await canUseCurrentLocation();
    if (!canUse) return null;
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );
    } catch (_) {
      return null;
    }
  }
}
