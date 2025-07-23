part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object> get props => [profile];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object> get props => [message];
}

class ProfileUpdateSuccess extends ProfileState {
  final String message;

  const ProfileUpdateSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class PasswordChangeSuccess extends ProfileState {
  final String message;

  const PasswordChangeSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class AvatarUploadSuccess extends ProfileState {
  final String avatarUrl;

  const AvatarUploadSuccess(this.avatarUrl);

  @override
  List<Object> get props => [avatarUrl];
}

class LogoutSuccess extends ProfileState {}