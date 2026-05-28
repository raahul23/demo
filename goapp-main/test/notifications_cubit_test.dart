import 'package:flutter_test/flutter_test.dart';

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

class FakeNotificationRepository implements NotificationRepository {
  int initCount = 0;
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

  @override
  Future<void> init() async {
    initCount += 1;
  }

  @override
  Future<void> showDriverAccepted({
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
  Future<void> showDriverArriving({
    required NotificationProgress progress,
  }) async {
    arrivingCount += 1;
    lastProgress = progress;
  }

  @override
  Future<void> showDriverArrived() async {
    arrivedCount += 1;
  }

  @override
  Future<void> showRideStarted({required String dropLabel}) async {
    rideStartedCount += 1;
    lastDropLabel = dropLabel;
  }

  @override
  Future<void> showRideProgress({
    required NotificationProgress progress,
  }) async {
    rideProgressCount += 1;
    lastProgress = progress;
  }

  @override
  Future<void> showRideCompleted({required String dropLabel}) async {
    rideCompletedCount += 1;
    lastDropLabel = dropLabel;
  }
}

void main() {
  NotificationsCubit buildCubit(
    FakeNotificationRepository repo, {
    Duration minUpdateInterval = const Duration(minutes: 1),
    int minPercentStep = 10,
  }) {
    return NotificationsCubit(
      initNotificationsUseCase: InitNotificationsUseCase(repo),
      showDriverAcceptedUseCase: ShowDriverAcceptedUseCase(repo),
      showDriverArrivingUseCase: ShowDriverArrivingUseCase(repo),
      showDriverArrivedUseCase: ShowDriverArrivedUseCase(repo),
      showRideStartedUseCase: ShowRideStartedUseCase(repo),
      showRideCompletedUseCase: ShowRideCompletedUseCase(repo),
      showRideProgressUseCase: ShowRideProgressUseCase(repo),
      minUpdateInterval: minUpdateInterval,
      minPercentStep: minPercentStep,
    );
  }

  test('driverAccepted initializes once and resets arriving progress', () async {
    final repo = FakeNotificationRepository();
    final cubit = buildCubit(repo);

    await cubit.driverAccepted(
      driverName: 'Driver',
      vehicle: 'Bike',
      progress: const NotificationProgress(
        percent: 10,
        etaMin: 8,
        distanceKm: 2.5,
      ),
    );

    expect(repo.initCount, 1);
    expect(repo.acceptedCount, 1);
    expect(cubit.state.lastArrivingPercent, isNull);

    await cubit.driverAccepted(
      driverName: 'Driver 2',
      vehicle: 'Auto',
      progress: const NotificationProgress(
        percent: 12,
        etaMin: 6,
        distanceKm: 2.0,
      ),
    );

    expect(repo.initCount, 1);
    expect(repo.acceptedCount, 2);
    await cubit.close();
  });

  test('driverArriving throttles rapid progress updates', () async {
    final repo = FakeNotificationRepository();
    final cubit = buildCubit(repo);

    await cubit.driverArriving(
      progress: const NotificationProgress(
        percent: 5,
        etaMin: 10,
        distanceKm: 3.0,
      ),
    );
    await cubit.driverArriving(
      progress: const NotificationProgress(
        percent: 7,
        etaMin: 9,
        distanceKm: 2.7,
      ),
    );

    expect(repo.arrivingCount, 1);

    await cubit.driverArriving(
      progress: const NotificationProgress(
        percent: 20,
        etaMin: 7,
        distanceKm: 2.0,
      ),
    );

    expect(repo.arrivingCount, 2);
    await cubit.close();
  });

  test('rideStarted resets ride progress state', () async {
    final repo = FakeNotificationRepository();
    final cubit = buildCubit(repo, minUpdateInterval: Duration.zero, minPercentStep: 1);

    await cubit.rideProgress(
      progress: const NotificationProgress(
        percent: 30,
        etaMin: 12,
        distanceKm: 5.0,
      ),
    );

    expect(repo.rideProgressCount, 1);
    expect(cubit.state.lastRidePercent, 30);

    await cubit.rideStarted(dropLabel: 'Drop');
    expect(repo.rideStartedCount, 1);
    expect(cubit.state.lastRidePercent, isNull);
    await cubit.close();
  });

  test('rideCompleted triggers completion notification', () async {
    final repo = FakeNotificationRepository();
    final cubit = buildCubit(repo);

    await cubit.rideCompleted(dropLabel: 'Drop');

    expect(repo.rideCompletedCount, 1);
    expect(repo.lastDropLabel, 'Drop');
    await cubit.close();
  });
}
