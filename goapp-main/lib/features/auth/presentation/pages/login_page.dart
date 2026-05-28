import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../cubit/auth_onboarding_cubit.dart';
import '../navigation/auth_route_transitions.dart';
import '../theme/auth_font_scope.dart';
import '../widgets/login_form.dart';
import '../widgets/onboarding_flow_scope.dart';
import 'bike_taxi_onboarding_page.dart';
import 'get_started_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key, this.onboardingCubit});

  final AuthOnboardingCubit? onboardingCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthOnboardingCubit>(
      create: (_) => onboardingCubit ?? getIt<AuthOnboardingCubit>(),
      child: BlocBuilder<AuthOnboardingCubit, AuthOnboardingState>(
        builder: (context, state) {
          if (state.loading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (state.seen) {
            return const AuthFontScope(
              child: Scaffold(body: LoginForm()),
            );
          }
          return AuthFontScope(
            child: GetStartedPage(
              onGetStarted: () {
                // Persist first entry from Get Started so auth intro is not shown again.
                unawaited(context.read<AuthOnboardingCubit>().markSeen());
                Navigator.of(context).push(
                  onboardingSlideRoute(
                    OnboardingFlowScope.wrapNext(
                      context,
                      const BikeTaxiOnboardingPage(),
                    ),
                  ),
                );
              },
              onSignIn: () {
                context.read<AuthOnboardingCubit>().markSeen();
                Navigator.of(context).push(loginFormRoute());
              },
            ),
          );
        },
      ),
    );
  }
}
