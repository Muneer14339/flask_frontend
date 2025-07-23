import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase implements UseCase<ProfileEntity, ProfileEntity> {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, ProfileEntity>> call(ProfileEntity params) async {
    return await repository.updateProfile(params);
  }
}