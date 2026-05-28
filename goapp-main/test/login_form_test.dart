import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/test_app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:goapp/core/error/failures.dart';
import 'package:goapp/core/utils/either.dart';
import 'package:goapp/features/auth/domain/entities/user.dart';
import 'package:goapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:goapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:goapp/features/auth/domain/usecases/request_otp_usecase.dart';
import 'package:goapp/features/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:goapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:goapp/features/auth/presentation/widgets/login_form.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, String>> requestOtp({required String phone}) async {
    return const Right('otp_123');
  }

  @override
  Future<Either<Failure, User>> login({
    required String phone,
    required String otp,
    String? otpId,
  }) async {
    return const Left(ServerFailure('Not used'));
  }

  @override
  Future<Either<Failure, void>> resendOtp({required String phone}) async {
    return const Right(null);
  }

  @override
  Future<bool> isLoggedIn() async => false;

  @override
  Future<void> logout() async {}
}

void main() {
  testWidgets('shows validation error when phone is empty', (tester) async {
    final repo = FakeAuthRepository();
    final bloc = AuthBloc(
      LoginUseCase(repo),
      RequestOtpUseCase(repo),
      ResendOtpUseCase(repo),
    );

    await tester.pumpWidget(
      TestApp(
        home: BlocProvider.value(
          value: bloc,
          child: const Scaffold(body: LoginForm()),
        ),
      ),
    );

    await tester.tap(find.text('Get Verification Code'));
    await tester.pump();

    expect(find.text('Mobile number is required'), findsAtLeastNWidgets(1));
  });
}
