import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/loadout_repository.dart';

class CompleteMaintenance implements UseCase<void, String> {
  final LoadoutRepository repository;

  CompleteMaintenance(this.repository);

  @override
  Future<Either<Failure, void>> call(String maintenanceId) async {
    return await repository.completeMaintenance(maintenanceId);
  }
}
