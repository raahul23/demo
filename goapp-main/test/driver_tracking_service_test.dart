import 'package:flutter_test/flutter_test.dart';

import 'package:goapp/features/booking/domain/entities/geo_point.dart';
import 'package:goapp/features/booking/domain/services/driver_tracking_service.dart';

void main() {
  test('trackToPickup follows encoded polyline path', () async {
    const service = DriverTrackingService(
      interval: Duration(milliseconds: 1),
      steps: 2,
    );
    const encodedPolyline = '_p~iF~ps|U_ulLnnqC_mqNvxq`@';
    const pickup = GeoPoint(lat: 38.5, lng: -120.2);

    final samples = await service
        .trackToPickup(
          pickup: pickup,
          encodedPath: encodedPolyline,
        )
        .toList();

    expect(samples, isNotEmpty);
    expect(samples.first.location.lat, closeTo(40.7, 1e-4));
    expect(samples.first.location.lng, closeTo(-120.95, 1e-4));
    expect(samples.last.location.lat, closeTo(pickup.lat, 1e-4));
    expect(samples.last.location.lng, closeTo(pickup.lng, 1e-4));
  });
}
