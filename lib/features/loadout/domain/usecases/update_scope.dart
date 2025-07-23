import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/scope.dart';
import '../repositories/loadout_repository.dart';

class UpdateScope implements UseCase<void, Scope> {
  final LoadoutRepository repository;

  UpdateScope(this.repository);

  @override
  Future<Either<Failure, void>> call(Scope scope) async {
    try {
      return await repository.updateScope(scope);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update scope: $e'));
    }
  }
}