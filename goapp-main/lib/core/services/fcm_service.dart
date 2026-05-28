import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FcmService {
  final FirebaseMessaging _messaging;

  FcmService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  Future<void> init() async {
    await _messaging.setAutoInitEnabled(true);

    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('FCM permission denied; token generation skipped');
      return;
    }

    if (!kIsWeb && Platform.isIOS) {
      final apnsToken = await _messaging.getAPNSToken();
      debugPrint('APNS token: $apnsToken');
    }

    final token = await _messaging.getToken();
    debugPrint('FCM token: $token');

    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM token refreshed: $newToken');
      // send token to backend when device registration API is ready.
    });
  }
}
