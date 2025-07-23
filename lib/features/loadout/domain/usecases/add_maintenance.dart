import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/maintenance.dart';
import '../repositories/loadout_repository.dart';

class AddMaintenance implements UseCase<void, Maintenance> {
  final LoadoutRepository repository;

  AddMaintenance(this.repository);

  @override
  Future<Either<Failure, void>> call(Maintenance maintenance) async {
    return await repository.addMaintenance(maintenance);
  }
}