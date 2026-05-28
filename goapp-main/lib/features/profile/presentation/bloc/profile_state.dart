import '../../domain/entities/profile.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileSuccess extends ProfileState {
  final Profile profile;

  ProfileSuccess(this.profile);
}

class ProfileFailure extends ProfileState {
  final String message;

  ProfileFailure(this.message);
}
