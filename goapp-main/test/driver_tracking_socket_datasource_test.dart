import 'package:flutter_test/flutter_test.dart';

import 'package:goapp/features/booking/data/datasources/driver_tracking_socket_datasource_impl.dart';

void main() {
  test('connect returns a broadcast stream', () {
    final dataSource = DriverTrackingSocketDataSourceImpl(
      baseUrl: 'http://localhost:3000',
      tokenProvider: () async => null, // No auth token — socket won't connect
    );

    final stream = dataSource.connect(rideId: 'ride-test-1');

    expect(stream.isBroadcast, isTrue);
    dataSource.disconnect();
  });

  test('stream closes after disconnect', () async {
    final dataSource = DriverTrackingSocketDataSourceImpl(
      baseUrl: 'http://localhost:3000',
      tokenProvider: () async => null,
    );

    final stream = dataSource.connect(rideId: 'ride-test-2');
    await dataSource.disconnect();

    await expectLater(stream, emitsDone);
  });
}
