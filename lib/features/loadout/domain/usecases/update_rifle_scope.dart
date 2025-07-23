import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/rifle.dart';
import '../entities/scope.dart';
import '../repositories/loadout_repository.dart';

class UpdateRifleScopeParams {
  final String rifleId;
  final Scope? scope;

  UpdateRifleScopeParams({required this.rifleId, this.scope});
}

class UpdateRifleScope implements UseCase<void, UpdateRifleScopeParams> {
  final LoadoutRepository repository;

  UpdateRifleScope(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateRifleScopeParams params) async {
    try {
      final riflesResult = await repository.getRifles();

      return riflesResult.fold(
            (failure) => Left(failure),
            (rifles) async {
          try {
            final rifle = rifles.firstWhere(
                  (r) => r.id == params.rifleId,
            );
            if(params.scope==null){
              final updatedRifle = rifle.copyWith(scope: params.scope,clearScope: true);
              return await repository.updateRifle(updatedRifle);

            }
            else {
              final updatedRifle = rifle.copyWith(scope: params.scope);
              return await repository.updateRifle(updatedRifle);

            }

          } catch (e) {
            return Left(DatabaseFailure('Rifle not found with ID: ${params.rifleId}'));
          }
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to update rifle scope: $e'));
    }
  }
}