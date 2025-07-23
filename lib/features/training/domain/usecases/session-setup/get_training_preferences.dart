import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../entities/session-setup/training_preferences.dart';
import '../../repositories/training_repository.dart';

class GetTrainingPreferences implements UseCase<TrainingPreferences, NoParams> {
  final TrainingRepository repository;

  GetTrainingPreferences(this.repository);

  @override
  Future<Either<Failure, TrainingPreferences>> call(NoParams params) async {
    return await repository.getTrainingPreferences();
  }
}
