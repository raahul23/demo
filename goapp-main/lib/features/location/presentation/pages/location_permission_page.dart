import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/presentation/pages/home_page.dart';
import '../../../../core/onboarding/onboarding_cubit.dart';
import '../../../../core/onboarding/onboarding_storage.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/location_permission_service.dart';
import '../../../activity/presentation/widgets/appbar.dart';
import '../cubit/location_access_cubit.dart';
import '../cubit/location_access_state.dart';
import '../../domain/usecases/get_location_deny_count_usecase.dart';
import '../../domain/usecases/increment_location_deny_count_usecase.dart';
import '../../domain/usecases/reset_location_deny_count_usecase.dart';

class LocationPermissionPage extends StatefulWidget {
  const LocationPermissionPage({super.key});

  @override
  State<LocationPermissionPage> createState() =>
      _LocationPermissionPageState();
}

class _LocationPermissionPageState extends State<LocationPermissionPage> {
  Future<void> _goHome() async {
    if (!mounted) return;
    try {
      await context.read<OnboardingCubit>().setStage(OnboardingStage.done);
    } catch (_) {
      // Fallback for flows where OnboardingCubit is not in the route tree.
      await getIt<OnboardingStorage>().setStage(OnboardingStage.done);
    }
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
        child: BlocProvider(
          create: (_) => LocationAccessCubit(
            getDenyCount: getIt<GetLocationDenyCountUseCase>(),
            incrementDenyCount: getIt<IncrementLocationDenyCountUseCase>(),
            resetDenyCount: getIt<ResetLocationDenyCountUseCase>(),
            permissionService: getIt<LocationPermissionService>(),
          ),
        child: Scaffold(
          appBar: const AppAppBar(
            title: 'Location Access',
            showBack: false,
          ),
          body: BlocListener<LocationAccessCubit, LocationAccessState>(
            listenWhen: (previous, current) =>
                previous.navigateToken != current.navigateToken &&
                current.navigateHome,
            listener: (context, state) async {
              final cubit = context.read<LocationAccessCubit>();
              await _goHome();
              if (!mounted) return;
              cubit.consumeNavigation();
            },
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Enable location to find nearby rides and show accurate pickup points.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<LocationAccessCubit, LocationAccessState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (state.loading || state.requesting)
                              ? null
                              : () => context
                                  .read<LocationAccessCubit>()
                                  .requestPermission(),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            disabledBackgroundColor:
                                Theme.of(context).colorScheme.primary,
                            disabledForegroundColor: Colors.white,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Opacity(
                                opacity: state.loading ? 0.0 : 1.0,
                                child: const Text('Allow'),
                              ),
                              if (state.loading)
                                const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<LocationAccessCubit, LocationAccessState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: (state.loading || state.requesting)
                              ? null
                              : () => context
                                  .read<LocationAccessCubit>()
                                  .denyAndContinue(),
                          child: const Text("Don't Allow"),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
