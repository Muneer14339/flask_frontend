import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ammunition.dart';
import '../repositories/loadout_repository.dart';

class AddAmmunition implements UseCase<void, Ammunition> {
  final LoadoutRepository repository;

  AddAmmunition(this.repository);

  @override
  Future<Either<Failure, void>> call(Ammunition ammunition) async {
    return await repository.addAmmunition(ammunition);
  }
}