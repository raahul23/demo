import 'package:flutter_test/flutter_test.dart';

import 'package:goapp/features/activity/domain/entities/ride_activity.dart';
import 'package:goapp/features/activity/domain/repositories/activity_repository.dart';
import 'package:goapp/features/activity/domain/usecases/download_receipt_usecase.dart';

class FakeActivityRepository implements ActivityRepository {
  String? lastRideId;

  @override
  Future<List<RideActivity>> getActivities() async => [];

  @override
  Future<bool> downloadReceipt(String rideId) async {
    lastRideId = rideId;
    return true;
  }
}

void main() {
  test('download receipt usecase delegates to repository', () async {
    final repo = FakeActivityRepository();
    final usecase = DownloadReceiptUseCase(repo);

    final result = await usecase('ride_1');

    expect(result, isTrue);
    expect(repo.lastRideId, 'ride_1');
  });
}
