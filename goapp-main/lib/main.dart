import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/di/injection.dart';
import 'core/onboarding/onboarding_cubit.dart';
import 'core/onboarding/onboarding_storage.dart';
import 'core/services/fcm_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/env.dart';
import 'firebase_options.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/cubit/auth_session_cubit.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/location/presentation/pages/location_permission_page.dart';
import 'features/profile/presentation/pages/profile_setup_page.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Env.load();
  await setupDependencies();
  await getIt<FcmService>().init();
  const enableDevicePreview = bool.fromEnvironment('DEVICE_PREVIEW');
  runApp(
    DevicePreview(
      enabled: enableDevicePreview,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const isTest = bool.fromEnvironment('FLUTTER_TEST');
    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'GoApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(isTest: isTest),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => getIt<AuthBloc>()),
          BlocProvider(create: (_) => getIt<AuthSessionCubit>()),
          BlocProvider(create: (_) => getIt<OnboardingCubit>()),
          BlocProvider(create: (_) => getIt<ProfileBloc>()),
        ],
        child: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) {
            return BlocBuilder<AuthSessionCubit, AuthSessionState>(
              builder: (context, authState) {
                return BlocBuilder<OnboardingCubit, OnboardingState>(
                  builder: (context, onboardingState) {
                    if (authState is AuthSessionLoading ||
                        onboardingState.loading) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (authState is! AuthSessionAuthenticated) {
                      return const LoginPage();
                    }
                    switch (onboardingState.stage) {
                      case OnboardingStage.profile:
                        return const ProfileSetupPage();
                      case OnboardingStage.location:
                        return const LocationPermissionPage();
                      case OnboardingStage.done:
                      case OnboardingStage.none:
                        return const HomePage();
                    }
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
