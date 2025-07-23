import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/rifle.dart';
import '../repositories/loadout_repository.dart';

class AddRifle implements UseCase<void, Rifle> {
  final LoadoutRepository repository;

  AddRifle(this.repository);

  @override
  Future<Either<Failure, void>> call(Rifle rifle) async {
    return await repository.addRifle(rifle);
  }
}