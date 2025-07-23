import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/rifle.dart';
import '../repositories/loadout_repository.dart';

class UpdateRifle implements UseCase<void, Rifle> {
  final LoadoutRepository repository;

  UpdateRifle(this.repository);

  @override
  Future<Either<Failure, void>> call(Rifle rifle) async {
    try {
      return await repository.updateRifle(rifle);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update rifle: $e'));
    }
  }
}