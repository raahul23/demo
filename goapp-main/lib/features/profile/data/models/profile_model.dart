import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  ProfileModel({
    required super.id,
    required super.name,
    required super.gender,
    required super.email,
    required super.emergencyContact,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      gender: json['gender'] ?? '',
      email: json['email'] ?? '',
      emergencyContact: json['emergency_contact'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'email': email,
      'emergency_contact': emergencyContact,
    };
  }
}
