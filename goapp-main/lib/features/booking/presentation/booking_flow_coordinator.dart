import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../notifications/presentation/cubit/notifications_cubit.dart';
import 'booking_background_coordinator.dart';
import 'booking_notification_handler.dart';
import 'cubit/booking_state.dart';

class BookingFlowCoordinator {
  final BookingBackgroundCoordinator backgroundCoordinator;
  final BookingNotificationHandler notificationHandler;
  final NotificationsCubit notificationsCubit;
  bool _initialized = false;

  BookingFlowCoordinator({
    required this.backgroundCoordinator,
    required this.notificationsCubit,
  }) : notificationHandler =
            BookingNotificationHandler(notificationsCubit: notificationsCubit);

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await notificationsCubit.init();
  }

  Future<void> handleState(BookingState state) async {
    await init();
    unawaited(backgroundCoordinator.handleBookingState(state));
    notificationHandler.handle(state);
  }

  Future<void> handleLifecycle(AppLifecycleState state) async {
    await backgroundCoordinator.handleLifecycle(state);
  }

  Future<void> dispose() async {
    await notificationsCubit.close();
  }
}
