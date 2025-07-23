import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/rifle.dart';
import '../repositories/loadout_repository.dart';

class GetRifles implements UseCase<List<Rifle>, NoParams> {
  final LoadoutRepository repository;

  GetRifles(this.repository);

  @override
  Future<Either<Failure, List<Rifle>>> call(NoParams params) async {
    return await repository.getRifles();
  }
}