import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../repositories/training_repository.dart';


class SaveAllSettings implements UseCase<void, NoParams> {
  final TrainingRepository repository;

  SaveAllSettings(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.saveAllSettings();
  }
}