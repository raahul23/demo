import 'package:flutter/services.dart';

import 'location_permission_service.dart';

class LocationPermissionServiceImpl implements LocationPermissionService {
  static const MethodChannel _channel =
      MethodChannel('native_permissions');

  @override
  Future<LocationPermissionStatus> requestWhenInUse() async {
    if (const bool.fromEnvironment('FLUTTER_TEST')) {
      return LocationPermissionStatus.granted;
    }
    final result = await _channel.invokeMethod<String>(
      'requestLocationWhenInUse',
    );
    return _mapStatus(result);
  }

  @override
  Future<bool> openSettings() async {
    if (const bool.fromEnvironment('FLUTTER_TEST')) {
      return true;
    }
    final result = await _channel.invokeMethod<bool>('openAppSettings');
    return result ?? false;
  }

  LocationPermissionStatus _mapStatus(String? raw) {
    switch (raw) {
      case 'granted':
        return LocationPermissionStatus.granted;
      case 'permanentlyDenied':
        return LocationPermissionStatus.permanentlyDenied;
      case 'restricted':
        return LocationPermissionStatus.restricted;
      default:
        return LocationPermissionStatus.denied;
    }
  }
}
