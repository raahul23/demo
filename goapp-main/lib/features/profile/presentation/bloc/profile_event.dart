abstract class ProfileEvent {}

class ProfileRequested extends ProfileEvent {}

class ProfileSubmitted extends ProfileEvent {
  final String name;
  final String gender;
  final String email;
  final String emergencyContact;

  ProfileSubmitted({
    required this.name,
    required this.gender,
    required this.email,
    required this.emergencyContact,
  });
}
