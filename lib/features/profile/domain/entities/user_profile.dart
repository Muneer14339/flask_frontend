import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? city;
  final String? state;
  final String? avatar;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;

  const ProfileEntity({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.city,
    this.state,
    this.avatar,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.smsNotifications = false,
  });

  @override
  List<Object?> get props => [
    id, fullName, email, phone, city, state, avatar,
    emailNotifications, pushNotifications, smsNotifications
  ];

  ProfileEntity copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? city,
    String? state,
    String? avatar,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      state: state ?? this.state,
      avatar: avatar ?? this.avatar,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
    );
  }
}