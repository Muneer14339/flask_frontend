import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../entities/session-setup/loadout_selection.dart';
import '../../repositories/training_repository.dart';

class GetLoadoutSelection implements UseCase<LoadoutSelection, NoParams> {
  final TrainingRepository repository;

  GetLoadoutSelection(this.repository);

  @override
  Future<Either<Failure, LoadoutSelection>> call(NoParams params) async {
    return await repository.getLoadoutSelection();
  }
}