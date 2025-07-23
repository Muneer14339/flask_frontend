import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../entities/session-setup/training_preferences.dart';
import '../../repositories/training_repository.dart';


class SaveTrainingPreferences implements UseCase<void, SaveTrainingPreferencesParams> {
  final TrainingRepository repository;

  SaveTrainingPreferences(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveTrainingPreferencesParams params) async {
    return await repository.saveTrainingPreferences(params.preferences);
  }
}

class SaveTrainingPreferencesParams extends Equatable {
  final TrainingPreferences preferences;

  const SaveTrainingPreferencesParams({required this.preferences});

  @override
  List<Object> get props => [preferences];
}