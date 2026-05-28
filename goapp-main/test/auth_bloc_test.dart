import 'package:flutter_test/flutter_test.dart';

import 'package:goapp/core/error/failures.dart';
import 'package:goapp/core/utils/either.dart';
import 'package:goapp/features/auth/domain/entities/user.dart';
import 'package:goapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:goapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:goapp/features/auth/domain/usecases/request_otp_usecase.dart';
import 'package:goapp/features/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:goapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:goapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:goapp/features/auth/presentation/bloc/auth_state.dart';

class FakeAuthRepository implements AuthRepository {
  Either<Failure, User>? result;
  Either<Failure, void>? resendResult;
  Either<Failure, String>? requestResult;

  @override
  Future<Either<Failure, User>> login({
    required String phone,
    required String otp,
    String? otpId,
  }) async {
    return result!;
  }

  @override
  Future<Either<Failure, String>> requestOtp({required String phone}) async {
    return requestResult ?? const Right('otp_123');
  }

  @override
  Future<Either<Failure, void>> resendOtp({required String phone}) async {
    return resendResult ?? const Right(null);
  }

  @override
  Future<bool> isLoggedIn() async => false;

  @override
  Future<void> logout() async {}
}

void main() {
  test('emits loading then success when login succeeds', () async {
    final repo = FakeAuthRepository()
      ..result = Right(User(id: '1', name: 'A', token: 't'));
    final useCase = LoginUseCase(repo);
    final requestUseCase = RequestOtpUseCase(repo);
    final resendUseCase = ResendOtpUseCase(repo);
    final bloc = AuthBloc(useCase, requestUseCase, resendUseCase);

    final statesFuture = expectLater(
      bloc.stream,
      emitsInOrder([isA<AuthLoading>(), isA<AuthSuccess>()]),
    );

    bloc.add(LoginRequested(phone: '123', otp: '0000'));
    await statesFuture;

    final state = bloc.state;
    expect(state, isA<AuthSuccess>());
    expect((state as AuthSuccess).user.id, '1');
  });

  test('emits loading then failure when login fails', () async {
    final repo = FakeAuthRepository()
      ..result = const Left(NetworkFailure('No internet'));
    final useCase = LoginUseCase(repo);
    final requestUseCase = RequestOtpUseCase(repo);
    final resendUseCase = ResendOtpUseCase(repo);
    final bloc = AuthBloc(useCase, requestUseCase, resendUseCase);

    final statesFuture = expectLater(
      bloc.stream,
      emitsInOrder([isA<AuthLoading>(), isA<AuthFailure>()]),
    );

    bloc.add(LoginRequested(phone: '123', otp: '0000'));
    await statesFuture;

    final state = bloc.state;
    expect(state, isA<AuthFailure>());
    expect((state as AuthFailure).message, 'No internet');
  });

  test('emits loading then resend success when resend succeeds', () async {
    final repo = FakeAuthRepository()
      ..result = Right(User(id: '1', name: 'A', token: 't'))
      ..resendResult = const Right(null);
    final useCase = LoginUseCase(repo);
    final requestUseCase = RequestOtpUseCase(repo);
    final resendUseCase = ResendOtpUseCase(repo);
    final bloc = AuthBloc(useCase, requestUseCase, resendUseCase);

    final statesFuture = expectLater(
      bloc.stream,
      emitsInOrder([isA<AuthLoading>(), isA<OtpResendSuccess>()]),
    );

    bloc.add(ResendOtpRequested(phone: '123'));
    await statesFuture;
  });

  test('emits loading then request success when request succeeds', () async {
    final repo = FakeAuthRepository()
      ..result = Right(User(id: '1', name: 'A', token: 't'))
      ..requestResult = const Right('otp_123');
    final useCase = LoginUseCase(repo);
    final requestUseCase = RequestOtpUseCase(repo);
    final resendUseCase = ResendOtpUseCase(repo);
    final bloc = AuthBloc(useCase, requestUseCase, resendUseCase);

    final statesFuture = expectLater(
      bloc.stream,
      emitsInOrder([isA<AuthLoading>(), isA<OtpRequestSuccess>()]),
    );

    bloc.add(RequestOtpRequested(phone: '123'));
    await statesFuture;
  });
}
