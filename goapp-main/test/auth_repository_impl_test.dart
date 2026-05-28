import 'package:flutter_test/flutter_test.dart';

import 'package:goapp/core/error/exceptions.dart';
import 'package:goapp/core/error/failures.dart';
import 'package:goapp/core/network/network_info.dart';
import 'package:goapp/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:goapp/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:goapp/features/auth/data/models/user_model.dart';
import 'package:goapp/features/auth/domain/entities/user.dart';
import 'package:goapp/features/auth/data/repositories/auth_repository_impl.dart';

class FakeNetworkInfo implements NetworkInfo {
  bool connected = true;

  @override
  Future<bool> get isConnected async => connected;

  @override
  Stream<bool> get onConnectivityChanged async* {
    yield connected;
  }
}

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  UserModel? userToReturn;
  Exception? exceptionToThrow;
  Exception? resendExceptionToThrow;
  String? otpIdToReturn;
  Exception? requestExceptionToThrow;

  @override
  Future<String> requestOtp({required String phone}) async {
    if (requestExceptionToThrow != null) {
      throw requestExceptionToThrow!;
    }
    return otpIdToReturn ?? 'otp_123';
  }

  @override
  Future<UserModel> login({
    required String phone,
    required String otp,
    String? otpId,
  }) async {
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return userToReturn!;
  }

  @override
  Future<void> resendOtp({required String phone}) async {
    if (resendExceptionToThrow != null) {
      throw resendExceptionToThrow!;
    }
  }
}

class FakeAuthLocalDataSource implements AuthLocalDataSource {
  String? token;

  @override
  Future<void> cacheToken(String token) async {
    this.token = token;
  }

  @override
  Future<void> clearToken() async {
    token = null;
  }

  @override
  Future<String?> getToken() async => token;
}

void main() {
  test('returns NetworkFailure when offline', () async {
    final networkInfo = FakeNetworkInfo()..connected = false;
    final remote = FakeAuthRemoteDataSource();
    final local = FakeAuthLocalDataSource();
    final repo = AuthRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      networkInfo: networkInfo,
    );

    final result = await repo.login(phone: '123', otp: '0000');

    expect(result.isLeft, true);
    result.fold(
      (failure) => expect(failure, isA<NetworkFailure>()),
      (_) => fail('Expected NetworkFailure'),
    );
  });

  test('returns ServerFailure when remote throws ServerException', () async {
    final networkInfo = FakeNetworkInfo()..connected = true;
    final remote = FakeAuthRemoteDataSource()
      ..exceptionToThrow = ServerException('Login failed');
    final local = FakeAuthLocalDataSource();
    final repo = AuthRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      networkInfo: networkInfo,
    );

    final result = await repo.login(phone: '123', otp: '0000');

    result.fold(
      (failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Login failed');
      },
      (_) => fail('Expected ServerFailure'),
    );
  });

  test('returns Right and caches token on success', () async {
    final networkInfo = FakeNetworkInfo()..connected = true;
    final remote = FakeAuthRemoteDataSource()
      ..userToReturn = UserModel(id: '1', name: 'A', token: 'token-123');
    final local = FakeAuthLocalDataSource();
    final repo = AuthRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      networkInfo: networkInfo,
    );

    final result = await repo.login(phone: '123', otp: '0000');

    result.fold(
      (_) => fail('Expected Right'),
      (user) {
        expect(user, isA<User>());
        expect(user.id, '1');
        expect(local.token, 'token-123');
      },
    );
  });

  test('requestOtp returns ServerFailure on error', () async {
    final networkInfo = FakeNetworkInfo()..connected = true;
    final remote = FakeAuthRemoteDataSource()
      ..requestExceptionToThrow = ServerException('Failed to send OTP');
    final local = FakeAuthLocalDataSource();
    final repo = AuthRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      networkInfo: networkInfo,
    );

    final result = await repo.requestOtp(phone: '123');

    result.fold(
      (failure) => expect(failure, isA<ServerFailure>()),
      (_) => fail('Expected ServerFailure'),
    );
  });

  test('requestOtp returns Right on success', () async {
    final networkInfo = FakeNetworkInfo()..connected = true;
    final remote = FakeAuthRemoteDataSource()..otpIdToReturn = 'otp_999';
    final local = FakeAuthLocalDataSource();
    final repo = AuthRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      networkInfo: networkInfo,
    );

    final result = await repo.requestOtp(phone: '123');

    result.fold(
      (_) => fail('Expected Right'),
      (otpId) => expect(otpId, 'otp_999'),
    );
  });

  test('resendOtp returns ServerFailure on error', () async {
    final networkInfo = FakeNetworkInfo()..connected = true;
    final remote = FakeAuthRemoteDataSource()
      ..resendExceptionToThrow = ServerException('Too many requests');
    final local = FakeAuthLocalDataSource();
    final repo = AuthRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      networkInfo: networkInfo,
    );

    final result = await repo.resendOtp(phone: '123');

    result.fold(
      (failure) => expect(failure, isA<ServerFailure>()),
      (_) => fail('Expected ServerFailure'),
    );
  });
}
