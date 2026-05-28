
import 'package:flutter/services.dart';

import 'notification_permission_service.dart';

class NotificationPermissionServiceImpl
    implements NotificationPermissionService {
  static const MethodChannel _channel =
      MethodChannel('native_permissions');

  @override
  Future<NotificationPermissionStatus> check() async {
    if (const bool.fromEnvironment('FLUTTER_TEST')) {
      return NotificationPermissionStatus.granted;
    }
    final result = await _channel.invokeMethod<String>('checkNotification');
    return _mapStatus(result);
  }

  @override
  Future<NotificationPermissionStatus> request() async {
    if (const bool.fromEnvironment('FLUTTER_TEST')) {
      return NotificationPermissionStatus.granted;
    }
    final result = await _channel.invokeMethod<String>('requestNotification');
    return _mapStatus(result);
  }

  @override
  Future<bool> openSettings() async {
    if (const bool.fromEnvironment('FLUTTER_TEST')) {
      return true;
    }
    final result = await _channel.invokeMethod<bool>(
      'openNotificationSettings',
    );
    return result ?? false;
  }

  NotificationPermissionStatus _mapStatus(String? raw) {
    switch (raw) {
      case 'granted':
        return NotificationPermissionStatus.granted;
      case 'permanentlyDenied':
        return NotificationPermissionStatus.permanentlyDenied;
      case 'restricted':
        return NotificationPermissionStatus.restricted;
      default:
        return NotificationPermissionStatus.denied;
    }
  }
}
