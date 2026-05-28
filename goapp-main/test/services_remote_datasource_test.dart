import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:goapp/core/network/api_client.dart';
import 'package:goapp/features/booking/domain/entities/booking_service.dart';
import 'package:goapp/features/services/data/datasources/services_remote_datasource_impl.dart';

ApiClient _failingApiClient() {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) => handler.reject(
      DioException(requestOptions: options, type: DioExceptionType.connectionError),
    ),
  ));
  return ApiClient(dio: dio);
}

void main() {
  test('fetchServices returns fallback list when API is unreachable', () async {
    final datasource = ServicesRemoteDataSourceImpl(_failingApiClient());
    final items = await datasource.fetchServices();

    // Fallback always includes the 3 core services (bike, auto, car)
    expect(items.length, greaterThanOrEqualTo(3));
    final bike = items.firstWhere((item) => item.id == 'bike');
    final car = items.firstWhere((item) => item.id == 'car');
    final auto = items.firstWhere((item) => item.id == 'auto');

    expect(bike.bookingService, BookingService.bike);
    expect(car.bookingService, BookingService.car);
    expect(auto.bookingService, BookingService.auto);
  });
}
