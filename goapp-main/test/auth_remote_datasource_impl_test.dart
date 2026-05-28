import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:goapp/core/error/exceptions.dart';
import 'package:goapp/core/network/api_client.dart';
import 'package:goapp/features/auth/data/datasources/auth_remote_datasource_impl.dart';

void main() {
  test('returns UserModel on success', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'id': '1',
                'name': 'User',
                'token': 'token-123',
              },
            ),
          );
        },
      ),
    );
    final apiClient = ApiClient(dio: dio);
    final dataSource = AuthRemoteDataSourceImpl(apiClient);

    final user = await dataSource.login(phone: '123', otp: '0000');

    expect(user.id, '1');
    expect(user.token, 'token-123');
  });

  test('throws ServerException on Dio error', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                statusCode: 400,
                data: {'message': 'Invalid OTP'},
              ),
            ),
          );
        },
      ),
    );
    final apiClient = ApiClient(dio: dio);
    final dataSource = AuthRemoteDataSourceImpl(apiClient);

    expect(
      () => dataSource.login(phone: '123', otp: '0000'),
      throwsA(isA<ServerException>()),
    );
  });
}
