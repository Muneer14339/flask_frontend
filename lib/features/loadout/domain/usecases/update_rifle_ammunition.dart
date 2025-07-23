import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/rifle.dart';
import '../entities/ammunition.dart';
import '../repositories/loadout_repository.dart';

class UpdateRifleAmmunitionParams {
  final String rifleId;
  final Ammunition? ammunition;

  UpdateRifleAmmunitionParams({required this.rifleId, this.ammunition});
}

class UpdateRifleAmmunition implements UseCase<void, UpdateRifleAmmunitionParams> {
  final LoadoutRepository repository;

  UpdateRifleAmmunition(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateRifleAmmunitionParams params) async {
    try {
      final riflesResult = await repository.getRifles();

      return riflesResult.fold(
            (failure) => Left(failure),
            (rifles) async {
          try {
            final rifle = rifles.firstWhere(
                  (r) => r.id == params.rifleId,
            );

            if(params.ammunition==null){
              final updatedRifle = rifle.copyWith(ammunition: params.ammunition, clearAmmunition: true);
              return await repository.updateRifle(updatedRifle);
            }else{
              final updatedRifle = rifle.copyWith(ammunition: params.ammunition);
              return await repository.updateRifle(updatedRifle);
            }

          } catch (e) {
            return Left(DatabaseFailure('Rifle not found with ID: ${params.rifleId}'));
          }
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to update rifle ammunition: $e'));
    }
  }
}