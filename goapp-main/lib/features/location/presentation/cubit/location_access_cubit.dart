import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_location_deny_count_usecase.dart';
import '../../domain/usecases/increment_location_deny_count_usecase.dart';
import '../../domain/usecases/reset_location_deny_count_usecase.dart';
import '../../../../core/services/location_permission_service.dart';
import 'location_access_state.dart';

class LocationAccessCubit extends Cubit<LocationAccessState> {
  final GetLocationDenyCountUseCase getDenyCount;
  final IncrementLocationDenyCountUseCase incrementDenyCount;
  final ResetLocationDenyCountUseCase resetDenyCount;
  final LocationPermissionService permissionService;
  bool _requesting = false;
  bool _navigating = false;

  LocationAccessCubit({
    required this.getDenyCount,
    required this.incrementDenyCount,
    required this.resetDenyCount,
    required this.permissionService,
  }) : super(LocationAccessState.initial());

  Future<void> requestPermission() async {
    if (_requesting || state.loading) return;
    _requesting = true;
    emit(state.copyWith(requesting: true));
    try {
      final denyCount = await getDenyCount();
      if (denyCount >= 2) {
        await permissionService.openSettings();
        return;
      }
      final status = await permissionService.requestWhenInUse();
      if (status == LocationPermissionStatus.granted) {
        await resetDenyCount();
        await _showLoadingAndNavigate();
        return;
      }
      await incrementDenyCount();
    } finally {
      _requesting = false;
      if (!_navigating) {
        emit(state.copyWith(requesting: false, loading: false));
      } else {
        emit(state.copyWith(requesting: false));
      }
    }
  }

  Future<void> denyAndContinue() async {
    await incrementDenyCount();
    _emitNavigate();
  }

  void consumeNavigation() {
    emit(state.copyWith(resetNavigate: true));
  }

  Future<void> _showLoadingAndNavigate() async {
    _navigating = true;
    emit(state.copyWith(loading: true));
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    _emitNavigate();
  }

  void _emitNavigate() {
    emit(
      state.copyWith(
        navigateHome: true,
        navigateToken: state.navigateToken + 1,
      ),
    );
  }
}
