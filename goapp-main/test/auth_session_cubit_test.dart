import 'package:flutter_test/flutter_test.dart';

import 'package:goapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:goapp/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:goapp/core/error/failures.dart';
import 'package:goapp/core/utils/either.dart';
import 'package:goapp/features/auth/domain/entities/user.dart';

class FakeAuthRepository implements AuthRepository {
  bool loggedIn = false;
  bool loggedOutCalled = false;

  @override
  Future<bool> isLoggedIn() async => loggedIn;

  @override
  Future<void> logout() async {
    loggedOutCalled = true;
    loggedIn = false;
  }

  @override
  Future<Either<Failure, User>> login({
    required String phone,
    required String otp,
    String? otpId,
  }) async => Right(User(id: '1', name: 'A', token: 't'));

  @override
  Future<Either<Failure, String>> requestOtp({required String phone}) async {
    return const Right('otp_123');
  }

  @override
  Future<Either<Failure, void>> resendOtp({required String phone}) async {
    return const Right(null);
  }
}

void main() {
  test('emits authenticated when logged in', () async {
    final repo = FakeAuthRepository()..loggedIn = true;
    final cubit = AuthSessionCubit(repo);

    await cubit.check();
    expect(cubit.state, isA<AuthSessionAuthenticated>());
  });

  test('emits unauthenticated when logged out', () async {
    final repo = FakeAuthRepository()..loggedIn = false;
    final cubit = AuthSessionCubit(repo);

    await cubit.check();
    expect(cubit.state, isA<AuthSessionUnauthenticated>());
  });

  test('logout clears session and emits unauthenticated', () async {
    final repo = FakeAuthRepository()..loggedIn = true;
    final cubit = AuthSessionCubit(repo);

    await cubit.logout();

    expect(repo.loggedOutCalled, true);
    expect(cubit.state, isA<AuthSessionUnauthenticated>());
  });
}
