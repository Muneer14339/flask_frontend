import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ammunition.dart';
import '../repositories/loadout_repository.dart';
class GetAmmunition implements UseCase<List<Ammunition>, NoParams> {
  final LoadoutRepository repository;

  GetAmmunition(this.repository);

  @override
  Future<Either<Failure, List<Ammunition>>> call(NoParams params) async {
    return await repository.getAmmunition();
  }
}