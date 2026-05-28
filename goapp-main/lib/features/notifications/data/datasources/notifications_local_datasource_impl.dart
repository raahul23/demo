import 'package:flutter/services.dart';

import '../../domain/entities/notification_progress.dart';
import 'notifications_local_datasource.dart';

class NotificationsLocalDataSourceImpl implements NotificationsLocalDataSource {
  static const String _channelId = 'ride_updates';
  static const String _channelName = 'Ride updates';
  static const MethodChannel _channel =
      MethodChannel('native_notifications');

  @override
  Future<void> init() async {
    if (const bool.fromEnvironment('FLUTTER_TEST')) {
      return;
    }
    await _channel.invokeMethod<void>('init', {
      'channelId': _channelId,
      'channelName': _channelName,
    });
  }

  @override
  Future<void> showDriverAccepted({
    required String driverName,
    required String vehicle,
    required NotificationProgress progress,
  }) {
    final title = 'Driver accepted your ride';
    final body =
        '$driverName • $vehicle\nETA ${progress.etaMin} min • ${progress.distanceKm.toStringAsFixed(1)} km';
    return _showNotification(
      id: 1001,
      title: title,
      body: body,
    );
  }

  @override
  Future<void> showDriverArriving({
    required NotificationProgress progress,
  }) {
    final title = 'Driver arriving';
    final body =
        'ETA ${progress.etaMin} min • ${progress.distanceKm.toStringAsFixed(1)} km';
    return _showNotification(
      id: 1002,
      title: title,
      body: body,
      progress: progress.percent,
      ongoing: true,
    );
  }

  @override
  Future<void> showDriverArrived() async {
    await _cancelNotification(1002);
    await _showNotification(
      id: 1003,
      title: 'Driver arrived at pickup',
      body: 'Your driver is waiting at the pickup point.',
    );
  }

  @override
  Future<void> showRideStarted({required String dropLabel}) async {
    await _cancelNotification(1002);
    await _showNotification(
      id: 1004,
      title: 'Ride started',
      body: 'Heading to $dropLabel',
      progress: 0,
      ongoing: true,
    );
  }

  @override
  Future<void> showRideProgress({
    required NotificationProgress progress,
  }) {
    final title = 'On the way to your destination';
    final body =
        'ETA ${progress.etaMin} min • ${progress.distanceKm.toStringAsFixed(1)} km';
    return _showNotification(
      id: 1004,
      title: title,
      body: body,
      progress: progress.percent,
      ongoing: true,
    );
  }

  @override
  Future<void> showRideCompleted({required String dropLabel}) async {
    await _cancelNotification(1004);
    await _showNotification(
      id: 1005,
      title: 'Arrived at destination',
      body: 'Reached $dropLabel',
    );
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    int? progress,
    bool ongoing = false,
  }) async {
    if (const bool.fromEnvironment('FLUTTER_TEST')) {
      return;
    }
    await _channel.invokeMethod<void>('show', {
      'id': id,
      'title': title,
      'body': body,
      'progress': progress,
      'ongoing': ongoing,
      'channelId': _channelId,
      'channelName': _channelName,
    });
  }

  Future<void> _cancelNotification(int id) async {
    if (const bool.fromEnvironment('FLUTTER_TEST')) {
      return;
    }
    await _channel.invokeMethod<void>('cancel', {'id': id});
  }
}
