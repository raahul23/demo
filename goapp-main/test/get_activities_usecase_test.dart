import 'package:flutter_test/flutter_test.dart';

import 'package:goapp/features/activity/domain/entities/ride_activity.dart';
import 'package:goapp/features/activity/domain/repositories/activity_repository.dart';
import 'package:goapp/features/activity/domain/usecases/get_activities_usecase.dart';

class FakeActivityRepository implements ActivityRepository {
  List<RideActivity> result = const [];

  @override
  Future<List<RideActivity>> getActivities() async => result;

  @override
  Future<bool> downloadReceipt(String rideId) async => true;
}

void main() {
  test('get activities usecase returns list', () async {
    final repo = FakeActivityRepository()
      ..result = [
        RideActivity(
          id: 'ride_1',
          status: RideActivityStatus.completed,
          cancelledBy: null,
          pickupLabel: 'A',
          dropLabel: 'B',
          startedAt: DateTime.now(),
          endedAt: DateTime.now(),
          distanceKm: 4.2,
          durationMin: 12,
          driver: const DriverSummary(
            name: 'Driver',
            vehicle: 'Car',
            plate: 'KA 02',
            rating: 4.7,
          ),
          payment: const PaymentSummary(
            fare: 120,
            method: 'Cash',
            transactionId: 'TXN2',
          ),
          supportNote: 'Help',
          receiptUrl: 'https://example.com',
        ),
      ];
    final usecase = GetActivitiesUseCase(repo);

    final rides = await usecase();

    expect(rides.length, 1);
    expect(rides.first.id, 'ride_1');
  });
}
