import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/scope.dart';
import '../repositories/loadout_repository.dart';

class GetScopes implements UseCase<List<Scope>, NoParams> {
  final LoadoutRepository repository;

  GetScopes(this.repository);

  @override
  Future<Either<Failure, List<Scope>>> call(NoParams params) async {
    return await repository.getScopes();
  }
}