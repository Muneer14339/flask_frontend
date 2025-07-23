import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/loadout_repository.dart';

class SetActiveRifle implements UseCase<void, String> {
  final LoadoutRepository repository;

  SetActiveRifle(this.repository);

  @override
  Future<Either<Failure, void>> call(String rifleId) async {
    return await repository.setActiveRifle(rifleId);
  }
}
