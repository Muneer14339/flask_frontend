import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/training_repository.dart';

class CalibrateSensors implements UseCase<void, NoParams> {
  final TrainingRepository repository;

  CalibrateSensors(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.calibrateSensors();
  }
}