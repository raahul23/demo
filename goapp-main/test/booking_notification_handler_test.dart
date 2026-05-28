import 'package:flutter_test/flutter_test.dart';

import 'package:goapp/features/booking/domain/entities/driver_info.dart';
import 'package:goapp/features/booking/domain/entities/driver_search_status.dart';
import 'package:goapp/features/booking/domain/entities/geo_point.dart';
import 'package:goapp/features/booking/domain/entities/booking_service.dart';
import 'package:goapp/features/booking/presentation/booking_notification_handler.dart';
import 'package:goapp/features/booking/presentation/cubit/booking_state.dart';
import 'package:goapp/features/notifications/domain/entities/notification_progress.dart';
import 'package:goapp/features/notifications/domain/repositories/notification_repository.dart';
import 'package:goapp/features/notifications/domain/usecases/init_notifications_usecase.dart';
import 'package:goapp/features/notifications/domain/usecases/show_driver_accepted_usecase.dart';
import 'package:goapp/features/notifications/domain/usecases/show_driver_arrived_usecase.dart';
import 'package:goapp/features/notifications/domain/usecases/show_driver_arriving_usecase.dart';
import 'package:goapp/features/notifications/domain/usecases/show_ride_completed_usecase.dart';
import 'package:goapp/features/notifications/domain/usecases/show_ride_progress_usecase.dart';
import 'package:goapp/features/notifications/domain/usecases/show_ride_started_usecase.dart';
import 'package:goapp/features/notifications/presentation/cubit/notifications_cubit.dart';

class _NoopNotificationRepository implements NotificationRepository {
  @override
  Future<void> init() async {}

  @override
  Future<void> showDriverAccepted({
    required String driverName,
    required String vehicle,
    required NotificationProgress progress,
  }) async {}

  @override
  Future<void> showDriverArriving({required NotificationProgress progress}) async {}

  @override
  Future<void> showDriverArrived() async {}

  @override
  Future<void> showRideStarted({required String dropLabel}) async {}

  @override
  Future<void> showRideProgress({required NotificationProgress progress}) async {}

  @override
  Future<void> showRideCompleted({required String dropLabel}) async {}
}

class _TestNotificationsCubit extends NotificationsCubit {
  int acceptedCount = 0;
  int arrivingCount = 0;
  int arrivedCount = 0;
  int rideStartedCount = 0;
  int rideProgressCount = 0;
  int rideCompletedCount = 0;
  NotificationProgress? lastProgress;
  String? lastDriverName;
  String? lastVehicle;
  String? lastDropLabel;

  _TestNotificationsCubit(NotificationRepository repo)
      : super(
          initNotificationsUseCase: InitNotificationsUseCase(repo),
          showDriverAcceptedUseCase: ShowDriverAcceptedUseCase(repo),
          showDriverArrivingUseCase: ShowDriverArrivingUseCase(repo),
          showDriverArrivedUseCase: ShowDriverArrivedUseCase(repo),
          showRideStartedUseCase: ShowRideStartedUseCase(repo),
          showRideCompletedUseCase: ShowRideCompletedUseCase(repo),
          showRideProgressUseCase: ShowRideProgressUseCase(repo),
          minUpdateInterval: Duration.zero,
          minPercentStep: 1,
        );

  @override
  Future<void> driverAccepted({
    required String driverName,
    required String vehicle,
    required NotificationProgress progress,
  }) async {
    acceptedCount += 1;
    lastDriverName = driverName;
    lastVehicle = vehicle;
    lastProgress = progress;
  }

  @override
  Future<void> driverArriving({required NotificationProgress progress}) async {
    arrivingCount += 1;
    lastProgress = progress;
  }

  @override
  Future<void> driverArrived() async {
    arrivedCount += 1;
  }

  @override
  Future<void> rideStarted({required String dropLabel}) async {
    rideStartedCount += 1;
    lastDropLabel = dropLabel;
  }

  @override
  Future<void> rideProgress({required NotificationProgress progress}) async {
    rideProgressCount += 1;
    lastProgress = progress;
  }

  @override
  Future<void> rideCompleted({required String dropLabel}) async {
    rideCompletedCount += 1;
    lastDropLabel = dropLabel;
  }
}

void main() {
  test('booking notification handler triggers expected notifications', () async {
    final cubit = _TestNotificationsCubit(_NoopNotificationRepository());
    final handler = BookingNotificationHandler(notificationsCubit: cubit);

    final baseState = BookingState.initial(
      pickup: const GeoPoint(lat: 12.0, lng: 77.0),
      drop: const GeoPoint(lat: 12.1, lng: 77.1),
      pickupLabel: 'Pickup',
      dropLabel: 'Drop',
    ).copyWith(
      distanceKm: 5.0,
      durationMin: 12,
    );

    handler.handle(baseState);

    final driver = const DriverInfo(
      name: 'Driver',
      vehicleModel: 'Bike',
      plateNumber: 'TN 01 0001',
      otp: '1234',
      phone: '+91 90000 0001',
      service: BookingService.bike,
    );

    final arriving = baseState.copyWith(
      driverSearchStatus: DriverSearchStatus.arriving,
      driverInfo: driver,
      driverArrivalMin: 10,
      driverArrivalInitialMin: 10,
      driverArrivalKm: 3.0,
    );
    handler.handle(arriving);

    expect(cubit.acceptedCount, 1);
    expect(cubit.lastDriverName, 'Driver');
    expect(cubit.lastVehicle, 'Bike • TN 01 0001');

    final arrivingProgress = arriving.copyWith(
      driverArrivalMin: 8,
      driverArrivalKm: 2.4,
    );
    handler.handle(arrivingProgress);
    expect(cubit.arrivingCount, 2);

    final arrived = arrivingProgress.copyWith(driverHasArrived: true);
    handler.handle(arrived);
    expect(cubit.arrivedCount, 1);

    final inRide = arrived.copyWith(
      driverSearchStatus: DriverSearchStatus.inRide,
      driverArrivalMin: 12,
      driverArrivalKm: 5.0,
    );
    handler.handle(inRide);
    expect(cubit.rideStartedCount, 1);
    expect(cubit.lastDropLabel, 'Drop');

    final inRideProgress = inRide.copyWith(
      driverArrivalMin: 6,
      driverArrivalKm: 2.5,
    );
    handler.handle(inRideProgress);
    expect(cubit.rideProgressCount, 2);

    final completed = inRideProgress.copyWith(
      driverSearchStatus: DriverSearchStatus.completed,
    );
    handler.handle(completed);
    expect(cubit.rideCompletedCount, 1);
  });
}
