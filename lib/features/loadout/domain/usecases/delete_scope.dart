// lib/features/Loadout/domain/usecases/delete_maintenance.dart
import 'package:dartz/dartz.dart';
import '../repositories/loadout_repository.dart';
import '../../../../core/error/failures.dart';

class DeleteScope {
  final LoadoutRepository repository;

  DeleteScope(this.repository);

  Future<Either<Failure, void>> call(String scopeId) async {
    return await repository.deleteScope(scopeId);
  
  }
}