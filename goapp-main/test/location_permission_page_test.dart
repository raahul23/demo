import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/test_app.dart';

import 'package:goapp/features/location/presentation/pages/location_permission_page.dart';
import 'package:goapp/core/onboarding/onboarding_cubit.dart';
import 'package:goapp/core/onboarding/onboarding_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/di/injection.dart';
import 'package:goapp/core/services/location_permission_service.dart';
import 'package:goapp/features/location/data/datasources/location_permission_storage.dart';
import 'package:goapp/features/location/data/repositories/location_permission_repository_impl.dart';
import 'package:goapp/features/location/domain/repositories/location_permission_repository.dart';
import 'package:goapp/features/location/domain/usecases/get_location_deny_count_usecase.dart';
import 'package:goapp/features/location/domain/usecases/increment_location_deny_count_usecase.dart';
import 'package:goapp/features/location/domain/usecases/reset_location_deny_count_usecase.dart';

class FakeLocationPermissionService implements LocationPermissionService {
  int openSettingsCount = 0;
  LocationPermissionStatus statusToReturn =
      LocationPermissionStatus.granted;
  int requestCount = 0;

  @override
  Future<LocationPermissionStatus> requestWhenInUse() async {
    requestCount += 1;
    return statusToReturn;
  }

  @override
  Future<bool> openSettings() async {
    openSettingsCount += 1;
    return true;
  }
}

Future<void> _registerLocationDeps(SharedPreferences prefs) async {
  if (getIt.isRegistered<LocationPermissionStorage>()) {
    getIt.unregister<LocationPermissionStorage>();
  }
  getIt.registerLazySingleton<LocationPermissionStorage>(
    () => LocationPermissionStorage(prefs),
  );
  if (getIt.isRegistered<LocationPermissionRepository>()) {
    getIt.unregister<LocationPermissionRepository>();
  }
  getIt.registerLazySingleton<LocationPermissionRepository>(
    () => LocationPermissionRepositoryImpl(
      storage: getIt<LocationPermissionStorage>(),
    ),
  );
  if (getIt.isRegistered<GetLocationDenyCountUseCase>()) {
    getIt.unregister<GetLocationDenyCountUseCase>();
  }
  getIt.registerLazySingleton<GetLocationDenyCountUseCase>(
    () => GetLocationDenyCountUseCase(getIt<LocationPermissionRepository>()),
  );
  if (getIt.isRegistered<IncrementLocationDenyCountUseCase>()) {
    getIt.unregister<IncrementLocationDenyCountUseCase>();
  }
  getIt.registerLazySingleton<IncrementLocationDenyCountUseCase>(
    () => IncrementLocationDenyCountUseCase(
      getIt<LocationPermissionRepository>(),
    ),
  );
  if (getIt.isRegistered<ResetLocationDenyCountUseCase>()) {
    getIt.unregister<ResetLocationDenyCountUseCase>();
  }
  getIt.registerLazySingleton<ResetLocationDenyCountUseCase>(
    () => ResetLocationDenyCountUseCase(getIt<LocationPermissionRepository>()),
  );
}

Future<FakeLocationPermissionService> _setup(
  SharedPreferences prefs,
) async {
  if (getIt.isRegistered<LocationPermissionService>()) {
    getIt.unregister<LocationPermissionService>();
  }
  final fakePlatform = FakeLocationPermissionService();
  getIt.registerLazySingleton<LocationPermissionService>(
    () => fakePlatform,
  );
  await _registerLocationDeps(prefs);
  return fakePlatform;
}

void main() {
  testWidgets('back navigation is blocked', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    if (getIt.isRegistered<SharedPreferences>()) {
      getIt.unregister<SharedPreferences>();
    }
    getIt.registerLazySingleton<SharedPreferences>(() => prefs);
    await _setup(prefs);
    final onboardingCubit = OnboardingCubit(OnboardingStorage(prefs));

    await tester.pumpWidget(
      TestApp(
        home: BlocProvider.value(
          value: onboardingCubit,
          child: const LocationPermissionPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(LocationPermissionPage), findsOneWidget);

    final dynamic widgetsBinding = tester.binding;
    await widgetsBinding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(LocationPermissionPage), findsOneWidget);
  });

  testWidgets('does not request location permission on load', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    if (getIt.isRegistered<SharedPreferences>()) {
      getIt.unregister<SharedPreferences>();
    }
    getIt.registerLazySingleton<SharedPreferences>(() => prefs);
    final fakePlatform = await _setup(prefs);
    final onboardingCubit = OnboardingCubit(OnboardingStorage(prefs));

    await tester.pumpWidget(
      TestApp(
        home: BlocProvider.value(
          value: onboardingCubit,
          child: const LocationPermissionPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(fakePlatform.requestCount, 0);
  });

  testWidgets('opens settings after two denies', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    if (getIt.isRegistered<SharedPreferences>()) {
      getIt.unregister<SharedPreferences>();
    }
    getIt.registerLazySingleton<SharedPreferences>(() => prefs);
    final fakePlatform = await _setup(prefs);
    fakePlatform.statusToReturn = LocationPermissionStatus.denied;
    final onboardingCubit = OnboardingCubit(OnboardingStorage(prefs));

    await tester.pumpWidget(
      TestApp(
        home: BlocProvider.value(
          value: onboardingCubit,
          child: const LocationPermissionPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(fakePlatform.requestCount, 0);
    expect(fakePlatform.openSettingsCount, 0);

    await tester.tap(find.text('Allow'));
    await tester.pumpAndSettle();
    expect(fakePlatform.requestCount, 1);

    await tester.tap(find.text('Allow'));
    await tester.pumpAndSettle();
    expect(fakePlatform.requestCount, 2);

    await tester.tap(find.text('Allow'));
    await tester.pumpAndSettle();

    expect(fakePlatform.openSettingsCount, 1);
  });

  testWidgets('dont allow marks onboarding done', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    if (getIt.isRegistered<SharedPreferences>()) {
      getIt.unregister<SharedPreferences>();
    }
    getIt.registerLazySingleton<SharedPreferences>(() => prefs);
    await _setup(prefs);
    final onboardingCubit = OnboardingCubit(OnboardingStorage(prefs));

    await tester.pumpWidget(
      TestApp(
        home: BlocProvider.value(
          value: onboardingCubit,
          child: const LocationPermissionPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text("Don't Allow"));
    await tester.pumpAndSettle();

    expect(onboardingCubit.state.stage, OnboardingStage.done);
  });

  testWidgets('shows loader before navigating on grant', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    if (getIt.isRegistered<SharedPreferences>()) {
      getIt.unregister<SharedPreferences>();
    }
    getIt.registerLazySingleton<SharedPreferences>(() => prefs);
    final fakePlatform = await _setup(prefs);
    fakePlatform.statusToReturn = LocationPermissionStatus.granted;
    final onboardingCubit = OnboardingCubit(OnboardingStorage(prefs));

    await tester.pumpWidget(
      TestApp(
        home: BlocProvider.value(
          value: onboardingCubit,
          child: const LocationPermissionPage(),
        ),
      ),
    );

    await tester.tap(find.text('Allow'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
  });
}