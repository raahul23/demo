enum NotificationPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
}

abstract class NotificationPermissionService {
  Future<NotificationPermissionStatus> check();
  Future<NotificationPermissionStatus> request();
  Future<bool> openSettings();
}
