import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/maintenance.dart';
import '../repositories/loadout_repository.dart';

class GetMaintenance implements UseCase<List<Maintenance>, NoParams> {
  final LoadoutRepository repository;

  GetMaintenance(this.repository);

  @override
  Future<Either<Failure, List<Maintenance>>> call(NoParams params) async {
    return await repository.getMaintenance();
  }
}