import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../../profile/data/datasources/profile_local_datasource.dart';

abstract class AuthSessionState {}

class AuthSessionLoading extends AuthSessionState {}

class AuthSessionAuthenticated extends AuthSessionState {}

class AuthSessionUnauthenticated extends AuthSessionState {}

class AuthSessionCubit extends Cubit<AuthSessionState> {
  final AuthRepository repository;
  final ProfileLocalDataSource? profileLocalDataSource;

  AuthSessionCubit(this.repository, {this.profileLocalDataSource})
    : super(AuthSessionLoading()) {
    check();
  }

  Future<void> check() async {
    emit(AuthSessionLoading());
    final loggedIn = await repository.isLoggedIn();
    if (loggedIn) {
      emit(AuthSessionAuthenticated());
    } else {
      emit(AuthSessionUnauthenticated());
    }
  }

  Future<void> logout() async {
    await repository.logout();
    if (profileLocalDataSource != null) {
      await profileLocalDataSource!.clearProfile();
    }
    emit(AuthSessionUnauthenticated());
  }

  /// Used by local/demo OTP flows where backend login is intentionally skipped.
  void markAuthenticatedForFlow() {
    emit(AuthSessionAuthenticated());
  }
}
