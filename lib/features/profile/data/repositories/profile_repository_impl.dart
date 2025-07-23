// import 'package:dartz/dartz.dart';
// import '../../../../core/error/failures.dart';
// import '../../domain/entities/user_profile.dart';
// import '../../domain/repositories/profile_repository.dart';
// import '../datasources/profile_remote_data_source.dart';
// import '../models/user_profile_model.dart';
//
// class ProfileRepositoryImpl implements ProfileRepository {
//   final ProfileRemoteDataSource remoteDataSource;
//
//   ProfileRepositoryImpl(this.remoteDataSource);
//
//   @override
//   Future<Either<Failure, ProfileEntity>> getProfile() async {
//     try {
//       final profile = await remoteDataSource.getProfile();
//       return Right(profile);
//     } catch (e) {
//       return Left(ServerFailure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, ProfileEntity>> updateProfile(ProfileEntity profile) async {
//     try {
//       final profileModel = ProfileModel(
//         id: profile.id,
//         fullName: profile.fullName,
//         email: profile.email,
//         phone: profile.phone,
//         city: profile.city,
//         state: profile.state,
//         avatar: profile.avatar,
//         emailNotifications: profile.emailNotifications,
//         pushNotifications: profile.pushNotifications,
//         smsNotifications: profile.smsNotifications,
//       );
//
//       final updatedProfile = await remoteDataSource.updateProfile(profileModel);
//       return Right(updatedProfile);
//     } catch (e) {
//       return Left(ServerFailure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, void>> changePassword(String currentPassword, String newPassword) async {
//     try {
//       await remoteDataSource.changePassword(currentPassword, newPassword);
//       return const Right(null);
//     } catch (e) {
//       return Left(ServerFailure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, void>> updateNotificationSettings(Map<String, bool> settings) async {
//     try {
//       await remoteDataSource.updateNotificationSettings(settings);
//       return const Right(null);
//     } catch (e) {
//       return Left(ServerFailure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, String>> uploadAvatar(String imagePath) async {
//     try {
//       final avatarUrl = await remoteDataSource.uploadAvatar(imagePath);
//       return Right(avatarUrl);
//     } catch (e) {
//       return Left(ServerFailure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, void>> logout() async {
//     try {
//       await remoteDataSource.logout();
//       return const Right(null);
//     } catch (e) {
//       return Left(ServerFailure());
//     }
//   }
// }