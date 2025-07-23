import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class UploadAvatarUseCase implements UseCase<String, String> {
  final ProfileRepository repository;

  UploadAvatarUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(String imagePath) async {
    return await repository.uploadAvatar(imagePath);
  }
}