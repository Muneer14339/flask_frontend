import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class UpdateNotificationSettingsUseCase implements UseCase<void, Map<String, bool>> {
  final ProfileRepository repository;

  UpdateNotificationSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(Map<String, bool> settings) async {
    return await repository.updateNotificationSettings(settings);
  }
}