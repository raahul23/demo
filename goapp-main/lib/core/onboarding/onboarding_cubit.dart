import 'package:flutter_bloc/flutter_bloc.dart';

import 'onboarding_storage.dart';

class OnboardingState {
  final bool loading;
  final OnboardingStage stage;

  const OnboardingState({
    required this.loading,
    required this.stage,
  });

  OnboardingState copyWith({bool? loading, OnboardingStage? stage}) {
    return OnboardingState(
      loading: loading ?? this.loading,
      stage: stage ?? this.stage,
    );
  }
}

class OnboardingCubit extends Cubit<OnboardingState> {
  final OnboardingStorage storage;

  OnboardingCubit(this.storage)
      : super(const OnboardingState(loading: true, stage: OnboardingStage.none)) {
    _load();
  }

  Future<void> _load() async {
    final stage = await storage.getStage();
    emit(state.copyWith(loading: false, stage: stage));
  }

  Future<void> setStage(OnboardingStage stage) async {
    await storage.setStage(stage);
    emit(state.copyWith(stage: stage));
  }

  Future<void> clear() async {
    await storage.clear();
    emit(state.copyWith(stage: OnboardingStage.none));
  }
}
