import 'package:flutter_test/flutter_test.dart';

import 'package:goapp/core/error/exceptions.dart';
import 'package:goapp/core/error/failures.dart';
import 'package:goapp/core/network/network_info.dart';
import 'package:goapp/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:goapp/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:goapp/features/profile/data/models/profile_model.dart';
import 'package:goapp/features/profile/data/repositories/profile_repository_impl.dart';

class FakeNetworkInfo implements NetworkInfo {
  bool connected = true;

  @override
  Future<bool> get isConnected async => connected;

  @override
  Stream<bool> get onConnectivityChanged async* {
    yield connected;
  }
}

class FakeProfileRemoteDataSource implements ProfileRemoteDataSource {
  ProfileModel? profileToReturn;
  Exception? exceptionToThrow;

  @override
  Future<ProfileModel> createProfile({
    required String name,
    required String gender,
    required String email,
    required String emergencyContact,
  }) async {
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return profileToReturn!;
  }
}

class FakeProfileLocalDataSource implements ProfileLocalDataSource {
  ProfileModel? cached;
  int cacheCalls = 0;
  int clearCalls = 0;

  @override
  Future<void> cacheProfile(ProfileModel profile) async {
    cacheCalls += 1;
    cached = profile;
  }

  @override
  Future<ProfileModel?> getCachedProfile() async => cached;

  @override
  Future<void> clearProfile() async {
    clearCalls += 1;
    cached = null;
  }
}

void main() {
  test('returns NetworkFailure when offline', () async {
    final networkInfo = FakeNetworkInfo()..connected = false;
    final remote = FakeProfileRemoteDataSource();
    final local = FakeProfileLocalDataSource();
    final repo = ProfileRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      networkInfo: networkInfo,
    );

    final result = await repo.createProfile(
      name: 'A',
      gender: 'Male',
      email: 'a@test.com',
      emergencyContact: '1234567890',
    );

    result.fold(
      (failure) => expect(failure, isA<NetworkFailure>()),
      (_) => fail('Expected NetworkFailure'),
    );
  });

  test('returns ServerFailure when remote throws ServerException', () async {
    final networkInfo = FakeNetworkInfo()..connected = true;
    final remote = FakeProfileRemoteDataSource()
      ..exceptionToThrow = ServerException('Profile failed');
    final local = FakeProfileLocalDataSource();
    final repo = ProfileRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      networkInfo: networkInfo,
    );

    final result = await repo.createProfile(
      name: 'A',
      gender: 'Male',
      email: 'a@test.com',
      emergencyContact: '1234567890',
    );

    result.fold(
      (failure) => expect(failure, isA<ServerFailure>()),
      (_) => fail('Expected ServerFailure'),
    );
  });

  test('returns Right on success', () async {
    final networkInfo = FakeNetworkInfo()..connected = true;
    final remote = FakeProfileRemoteDataSource()
      ..profileToReturn = ProfileModel(
        id: 'p1',
        name: 'A',
        gender: 'Male',
        email: 'a@test.com',
        emergencyContact: '1234567890',
      );
    final local = FakeProfileLocalDataSource();
    final repo = ProfileRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      networkInfo: networkInfo,
    );

    final result = await repo.createProfile(
      name: 'A',
      gender: 'Male',
      email: 'a@test.com',
      emergencyContact: '1234567890',
    );

    result.fold(
      (_) => fail('Expected Right'),
      (profile) => expect(profile.id, 'p1'),
    );
    expect(local.cacheCalls, 1);
  });
}
