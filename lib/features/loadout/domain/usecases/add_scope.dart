import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/scope.dart';
import '../repositories/loadout_repository.dart';

class AddScope implements UseCase<void, Scope> {
  final LoadoutRepository repository;

  AddScope(this.repository);

  @override
  Future<Either<Failure, void>> call(Scope scope) async {
    return await repository.addScope(scope);
  }
}