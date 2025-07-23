import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ammunition.dart';
import '../repositories/loadout_repository.dart';

class UpdateAmmunition implements UseCase<void, Ammunition> {
  final LoadoutRepository repository;

  UpdateAmmunition(this.repository);

  @override
  Future<Either<Failure, void>> call(Ammunition ammunition) async {
    try {
      return await repository.updateAmmunition(ammunition);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update ammunition: $e'));
    }
  }
}