import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/onboarding/onboarding_storage.dart';

class AuthOnboardingState {
  const AuthOnboardingState({
    required this.loading,
    required this.seen,
  });

  final bool loading;
  final bool seen;

  AuthOnboardingState copyWith({
    bool? loading,
    bool? seen,
  }) {
    return AuthOnboardingState(
      loading: loading ?? this.loading,
      seen: seen ?? this.seen,
    );
  }
}

class AuthOnboardingCubit extends Cubit<AuthOnboardingState> {
  AuthOnboardingCubit(this._storage)
      : super(const AuthOnboardingState(loading: true, seen: false)) {
    _load();
  }

  final OnboardingStorage _storage;

  Future<void> _load() async {
    final seen = await _storage.getAuthIntroSeen();
    emit(state.copyWith(loading: false, seen: seen));
  }

  Future<void> markSeen() async {
    await _storage.setAuthIntroSeen(true);
    emit(state.copyWith(seen: true));
  }

  Future<void> reset() async {
    await _storage.setAuthIntroSeen(false);
    emit(state.copyWith(seen: false));
  }
}
