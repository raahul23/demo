import 'package:google_maps_flutter/google_maps_flutter.dart';

enum HomeLocationPromptType {
  service,
  permission,
}

class HomeLocationState {
  final LatLng? current;
  final bool locationDenied;
  final HomeLocationPromptType? promptType;
  final int promptId;
  final bool pendingRetry;

  const HomeLocationState({
    required this.current,
    required this.locationDenied,
    required this.promptType,
    required this.promptId,
    required this.pendingRetry,
  });

  factory HomeLocationState.initial() {
    return const HomeLocationState(
      current: null,
      locationDenied: false,
      promptType: null,
      promptId: 0,
      pendingRetry: false,
    );
  }

  HomeLocationState copyWith({
    LatLng? current,
    bool? locationDenied,
    HomeLocationPromptType? promptType,
    int? promptId,
    bool? pendingRetry,
    bool clearPrompt = false,
  }) {
    return HomeLocationState(
      current: current ?? this.current,
      locationDenied: locationDenied ?? this.locationDenied,
      promptType: clearPrompt ? null : (promptType ?? this.promptType),
      promptId: promptId ?? this.promptId,
      pendingRetry: pendingRetry ?? this.pendingRetry,
    );
  }
}
