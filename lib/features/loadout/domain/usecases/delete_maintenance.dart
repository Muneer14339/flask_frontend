// lib/features/Loadout/domain/usecases/delete_maintenance.dart
import 'package:dartz/dartz.dart';
import '../repositories/loadout_repository.dart';
import '../../../../core/error/failures.dart';

class DeleteMaintenance {
  final LoadoutRepository repository;

  DeleteMaintenance(this.repository);

  Future<Either<Failure, void>> call(String maintenanceId) async {
    return await repository.deleteMaintenance(maintenanceId);
  
  }
}