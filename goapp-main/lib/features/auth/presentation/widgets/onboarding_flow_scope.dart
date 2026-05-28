import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth_onboarding_cubit.dart';
import '../navigation/auth_route_transitions.dart';

class OnboardingFlowScope extends StatelessWidget {
  const OnboardingFlowScope({
    super.key,
    required this.cubit,
    required this.child,
  });

  final AuthOnboardingCubit cubit;
  final Widget child;

  static Widget wrapNext(BuildContext context, Widget child) {
    try {
      return OnboardingFlowScope(
        cubit: context.read<AuthOnboardingCubit>(),
        child: child,
      );
    } catch (_) {
      return child;
    }
  }

  static void finishToLogin(BuildContext context) {
    try {
      context.read<AuthOnboardingCubit>().markSeen();
    } catch (_) {}
    Navigator.of(context).pushAndRemoveUntil(loginFormRoute(), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthOnboardingCubit>.value(
      value: cubit,
      child: child,
    );
  }
}
