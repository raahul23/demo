import 'package:flutter_test/flutter_test.dart';

import 'package:goapp/features/activity/data/datasources/activity_remote_datasource.dart';
import 'package:goapp/features/activity/data/repositories/activity_repository_impl.dart';
import 'package:goapp/features/activity/domain/entities/ride_activity.dart';
import 'package:goapp/features/activity/domain/repositories/activity_repository.dart';

class FakeActivityRemoteDataSource implements ActivityRemoteDataSource {
  int fetchCalls = 0;
  int receiptCalls = 0;
  List<RideActivity> result = const [];

  @override
  Future<List<RideActivity>> fetchActivities() async {
    fetchCalls += 1;
    return result;
  }

  @override
  Future<bool> downloadReceipt(String rideId) async {
    receiptCalls += 1;
    return true;
  }
}

void main() {
  test('repository delegates to remote datasource', () async {
    final remote = FakeActivityRemoteDataSource()
      ..result = [
        RideActivity(
          id: 'ride_1',
          status: RideActivityStatus.completed,
          cancelledBy: null,
          pickupLabel: 'A',
          dropLabel: 'B',
          startedAt: DateTime.now(),
          endedAt: DateTime.now(),
          distanceKm: 1.2,
          durationMin: 5,
          driver: const DriverSummary(
            name: 'Driver',
            vehicle: 'Bike',
            plate: 'KA 01',
            rating: 4.5,
          ),
          payment: const PaymentSummary(
            fare: 50,
            method: 'UPI',
            transactionId: 'TXN1',
          ),
          supportNote: 'Help',
          receiptUrl: 'https://example.com',
        ),
      ];
    final ActivityRepository repository = ActivityRepositoryImpl(
      remoteDataSource: remote,
    );

    final rides = await repository.getActivities();
    await repository.downloadReceipt('ride_1');

    expect(remote.fetchCalls, 1);
    expect(remote.receiptCalls, 1);
    expect(rides.length, 1);
  });
}
