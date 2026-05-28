import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:goapp/core/network/api_client.dart';
import 'package:goapp/features/activity/data/datasources/activity_remote_datasource_impl.dart';

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
  test('fetchActivities returns empty list when API is unreachable', () async {
    final datasource = ActivityRemoteDataSourceImpl(_failingApiClient());
    final rides = await datasource.fetchActivities();
    expect(rides, isEmpty);
  });

  test('downloadReceipt returns false when API is unreachable', () async {
    final datasource = ActivityRemoteDataSourceImpl(_failingApiClient());
    final result = await datasource.downloadReceipt('ride_101');
    expect(result, isFalse);
  });
}
