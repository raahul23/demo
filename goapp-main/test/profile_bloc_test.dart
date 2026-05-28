import 'package:flutter_test/flutter_test.dart';

import 'package:goapp/core/error/failures.dart';
import 'package:goapp/core/utils/either.dart';
import 'package:goapp/features/profile/domain/entities/profile.dart';
import 'package:goapp/features/profile/domain/repositories/profile_repository.dart';
import 'package:goapp/features/profile/domain/usecases/create_profile_usecase.dart';
import 'package:goapp/features/profile/domain/usecases/get_cached_profile_usecase.dart';
import 'package:goapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:goapp/features/profile/presentation/bloc/profile_event.dart';
import 'package:goapp/features/profile/presentation/bloc/profile_state.dart';

class FakeProfileRepository implements ProfileRepository {
  Either<Failure, Profile>? result;
  Profile? cachedProfile;

  @override
  Future<Either<Failure, Profile>> createProfile({
    required String name,
    required String gender,
    required String email,
    required String emergencyContact,
  }) async {
    return result!;
  }

  @override
  Future<Either<Failure, Profile?>> getCachedProfile() async {
    return Right(cachedProfile);
  }
}

void main() {
  test('emits loading then success when create succeeds', () async {
    final repo = FakeProfileRepository()
      ..result = Right(
        Profile(
          id: 'p1',
          name: 'A',
          gender: 'Male',
          email: 'a@test.com',
          emergencyContact: '1234567890',
        ),
      );
    final bloc = ProfileBloc(
      CreateProfileUseCase(repo),
      GetCachedProfileUseCase(repo),
      autoLoad: false,
    );

    final statesFuture = expectLater(
      bloc.stream,
      emitsInOrder([isA<ProfileLoading>(), isA<ProfileSuccess>()]),
    );

    bloc.add(
      ProfileSubmitted(
        name: 'A',
        gender: 'Male',
        email: 'a@test.com',
        emergencyContact: '1234567890',
      ),
    );
    await statesFuture;
  });

  test('emits loading then failure when create fails', () async {
    final repo = FakeProfileRepository()
      ..result = const Left(ServerFailure('Bad request'));
    final bloc = ProfileBloc(
      CreateProfileUseCase(repo),
      GetCachedProfileUseCase(repo),
      autoLoad: false,
    );

    final statesFuture = expectLater(
      bloc.stream,
      emitsInOrder([isA<ProfileLoading>(), isA<ProfileFailure>()]),
    );

    bloc.add(
      ProfileSubmitted(
        name: 'A',
        gender: 'Male',
        email: 'a@test.com',
        emergencyContact: '1234567890',
      ),
    );
    await statesFuture;
  });

  test('emits cached profile when requested', () async {
    final repo = FakeProfileRepository()
      ..cachedProfile = Profile(
        id: 'p2',
        name: 'B',
        gender: 'Female',
        email: 'b@test.com',
        emergencyContact: '9876543210',
      );
    final bloc = ProfileBloc(
      CreateProfileUseCase(repo),
      GetCachedProfileUseCase(repo),
      autoLoad: false,
    );

    final statesFuture = expectLater(
      bloc.stream,
      emitsInOrder([isA<ProfileSuccess>()]),
    );

    bloc.add(ProfileRequested());
    await statesFuture;
  });
}
