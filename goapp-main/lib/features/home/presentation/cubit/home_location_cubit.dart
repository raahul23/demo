import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'home_location_state.dart';

class HomeLocationCubit extends Cubit<HomeLocationState> {
  final bool autoStart;
  StreamSubscription<Position>? _positionSub;
  bool _initInFlight = false;

  HomeLocationCubit({
    this.autoStart = true,
  }) : super(HomeLocationState.initial());

  Future<void> init() async {
    if (!autoStart) return;
    await requestCurrentLocation();
  }

  Future<void> retryIfPending() async {
    if (!state.pendingRetry) return;
    emit(state.copyWith(pendingRetry: false));
    await requestCurrentLocation();
  }

  Future<void> openSettings(HomeLocationPromptType type) async {
    emit(state.copyWith(pendingRetry: true, clearPrompt: true));
    if (type == HomeLocationPromptType.service) {
      await Geolocator.openLocationSettings();
    } else {
      await Geolocator.openAppSettings();
    }
  }

  Future<void> requestCurrentLocation() async {
    if (_initInFlight) return;
    _initInFlight = true;
    await _initLocation();
    _initInFlight = false;
  }

  Future<void> _initLocation() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      emit(
        state.copyWith(
          locationDenied: true,
          promptType: HomeLocationPromptType.service,
          promptId: state.promptId + 1,
        ),
      );
      _stopTracking();
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (!kIsWeb && permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      emit(
        state.copyWith(
          locationDenied: true,
          promptType: HomeLocationPromptType.permission,
          promptId: state.promptId + 1,
        ),
      );
      _stopTracking();
      return;
    }

    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: _currentPositionSettings(),
      );
    } catch (_) {
      emit(
        state.copyWith(
          locationDenied: true,
          promptType: HomeLocationPromptType.permission,
          promptId: state.promptId + 1,
        ),
      );
      _stopTracking();
      return;
    }
    emit(
      state.copyWith(
        current: LatLng(position.latitude, position.longitude),
        locationDenied: false,
        clearPrompt: true,
      ),
    );
    _startTracking();
  }

  void _startTracking() {
    _positionSub?.cancel();
    _positionSub = Geolocator.getPositionStream(
      locationSettings: _streamPositionSettings(),
    ).listen((pos) {
      emit(
        state.copyWith(
          current: LatLng(pos.latitude, pos.longitude),
          locationDenied: false,
        ),
      );
    });
  }

  void _stopTracking() {
    _positionSub?.cancel();
    _positionSub = null;
  }

  LocationSettings _currentPositionSettings() {
    if (kIsWeb) {
      return const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      );
    }
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
        intervalDuration: const Duration(seconds: 2),
      );
    }
    if (Platform.isIOS || Platform.isMacOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        activityType: ActivityType.other,
        pauseLocationUpdatesAutomatically: true,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
    );
  }

  LocationSettings _streamPositionSettings() {
    if (kIsWeb) {
      return const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
    }
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        intervalDuration: const Duration(seconds: 2),
      );
    }
    if (Platform.isIOS || Platform.isMacOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.other,
        pauseLocationUpdatesAutomatically: true,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
  }

  @override
  Future<void> close() {
    _stopTracking();
    return super.close();
  }
}
