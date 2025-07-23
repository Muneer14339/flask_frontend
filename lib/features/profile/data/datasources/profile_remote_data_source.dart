import 'package:dio/dio.dart';

import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updateProfile(ProfileModel profile);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> updateNotificationSettings(Map<String, bool> settings);
  Future<String> uploadAvatar(String imagePath);
  Future<void> logout();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl(this.dio);

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final response = await dio.get('/api/profile');
      return ProfileModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  @override
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    try {
      final response = await dio.put(
        '/api/profile',
        data: profile.toJson(),
      );
      return ProfileModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await dio.post('/api/profile/change-password', data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      });
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  @override
  Future<void> updateNotificationSettings(Map<String, bool> settings) async {
    try {
      await dio.put('/api/profile/notifications', data: settings);
    } catch (e) {
      throw Exception('Failed to update notification settings: $e');
    }
  }

  @override
  Future<String> uploadAvatar(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(imagePath),
      });

      final response = await dio.post('/api/profile/avatar', data: formData);
      return response.data['avatar_url'];
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dio.post('/api/auth/logout');
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }
}
