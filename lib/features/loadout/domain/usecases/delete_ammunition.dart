import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/loadout_repository.dart';

class DeleteAmmunition implements UseCase<void, String> {
  final LoadoutRepository repository;

  DeleteAmmunition(this.repository);

  @override
  Future<Either<Failure, void>> call(String ammunitionId) async {
    return await repository.deleteAmmunition(ammunitionId);
  }
}