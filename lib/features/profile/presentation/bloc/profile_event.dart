part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class GetProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final ProfileEntity profile;

  const UpdateProfileEvent(this.profile);

  @override
  List<Object> get props => [profile];
}

class ChangePasswordEvent extends ProfileEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [currentPassword, newPassword];
}

class UpdateNotificationSettingsEvent extends ProfileEvent {
  final Map<String, bool> settings;

  const UpdateNotificationSettingsEvent(this.settings);

  @override
  List<Object> get props => [settings];
}

class UploadAvatarEvent extends ProfileEvent {
  final String imagePath;

  const UploadAvatarEvent(this.imagePath);

  @override
  List<Object> get props => [imagePath];
}

class LogoutEvent extends ProfileEvent {}