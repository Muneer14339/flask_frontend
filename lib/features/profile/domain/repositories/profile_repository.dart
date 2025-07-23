import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_profile.dart';


abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile();
  Future<Either<Failure, ProfileEntity>> updateProfile(ProfileEntity profile);
  Future<Either<Failure, void>> changePassword(String currentPassword, String newPassword);
  Future<Either<Failure, void>> updateNotificationSettings(Map<String, bool> settings);
  Future<Either<Failure, String>> uploadAvatar(String imagePath);
  Future<Either<Failure, void>> logout();
}
