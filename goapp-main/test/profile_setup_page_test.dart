import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/test_app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:goapp/core/error/failures.dart';
import 'package:goapp/core/utils/either.dart';
import 'package:goapp/features/profile/domain/entities/profile.dart';
import 'package:goapp/features/profile/domain/repositories/profile_repository.dart';
import 'package:goapp/features/profile/domain/usecases/create_profile_usecase.dart';
import 'package:goapp/features/profile/domain/usecases/get_cached_profile_usecase.dart';
import 'package:goapp/features/profile/presentation/bloc/profile_bloc.dart';

import 'package:goapp/features/profile/presentation/pages/profile_setup_page.dart';
import 'package:goapp/core/onboarding/onboarding_cubit.dart';
import 'package:goapp/core/onboarding/onboarding_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeProfileRepository implements ProfileRepository {
  Profile? cachedProfile;

  @override
  Future<Either<Failure, Profile>> createProfile({
    required String name,
    required String gender,
    required String email,
    required String emergencyContact,
  }) async {
    return const Left(ServerFailure('Not used'));
  }

  @override
  Future<Either<Failure, Profile?>> getCachedProfile() async {
    return Right(cachedProfile);
  }
}

void main() {
  testWidgets('back navigation is blocked', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final onboardingCubit = OnboardingCubit(OnboardingStorage(prefs));
    final bloc = ProfileBloc(
      CreateProfileUseCase(FakeProfileRepository()),
      GetCachedProfileUseCase(FakeProfileRepository()),
      autoLoad: false,
    );

    await tester.pumpWidget(
      TestApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: bloc),
            BlocProvider.value(value: onboardingCubit),
          ],
          child: const ProfileSetupPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(ProfileSetupPage), findsOneWidget);

    final dynamic widgetsBinding = tester.binding;
    await widgetsBinding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(ProfileSetupPage), findsOneWidget);
  });
  testWidgets('shows validation errors on empty submit', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final onboardingCubit = OnboardingCubit(OnboardingStorage(prefs));
    final bloc = ProfileBloc(
      CreateProfileUseCase(FakeProfileRepository()),
      GetCachedProfileUseCase(FakeProfileRepository()),
      autoLoad: false,
    );

    await tester.pumpWidget(
      TestApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: bloc),
            BlocProvider.value(value: onboardingCubit),
          ],
          child: const ProfileSetupPage(),
        ),
      ),
    );

    await tester.tap(find.text('Save Profile'));
    await tester.pump();

    expect(find.text('Name is required'), findsOneWidget);
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Emergency contact is required'), findsOneWidget);
  });

  testWidgets('shows validation errors for invalid inputs', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final onboardingCubit = OnboardingCubit(OnboardingStorage(prefs));
    final bloc = ProfileBloc(
      CreateProfileUseCase(FakeProfileRepository()),
      GetCachedProfileUseCase(FakeProfileRepository()),
      autoLoad: false,
    );

    await tester.pumpWidget(
      TestApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: bloc),
            BlocProvider.value(value: onboardingCubit),
          ],
          child: const ProfileSetupPage(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), '1');
    await tester.enterText(find.byType(TextFormField).at(1), 'invalid@');
    await tester.enterText(find.byType(TextFormField).at(2), '0000000000');

    await tester.tap(find.text('Save Profile'));
    await tester.pump();

    expect(find.text('Name is required'), findsOneWidget);
    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(find.text('Invalid emergency contact'), findsOneWidget);
  });

  testWidgets('prefills form fields from cached profile', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final onboardingCubit = OnboardingCubit(OnboardingStorage(prefs));
    final repo = FakeProfileRepository()..cachedProfile = Profile(
      id: 'p1',
      name: 'Alice',
      gender: 'Female',
      email: 'alice@test.com',
      emergencyContact: '1234567890',
    );
    final bloc = ProfileBloc(
      CreateProfileUseCase(repo),
      GetCachedProfileUseCase(repo),
      autoLoad: false,
    );

    await tester.pumpWidget(
      TestApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: bloc),
            BlocProvider.value(value: onboardingCubit),
          ],
          child: const ProfileSetupPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final nameField =
        tester.widget<TextFormField>(find.byType(TextFormField).at(0));
    final emailField =
        tester.widget<TextFormField>(find.byType(TextFormField).at(1));
    final emergencyField =
        tester.widget<TextFormField>(find.byType(TextFormField).at(2));

    expect(nameField.controller?.text, 'Alice');
    expect(emailField.controller?.text, 'alice@test.com');
    expect(emergencyField.controller?.text, '1234567890');
    expect(find.text('Female'), findsOneWidget);
  });
}