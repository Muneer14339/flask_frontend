// Debug version of UpdateRifleAmmunition to help troubleshoot
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
      print('🔧 UpdateRifleAmmunition: Starting update for rifle ${params.rifleId}');
      print('🔧 New ammunition: ${params.ammunition?.name ?? 'NULL (removing)'}');

      final riflesResult = await repository.getRifles();

      return riflesResult.fold(
            (failure) {
          print('❌ Failed to get rifles: $failure');
          return Left(failure);
        },
            (rifles) async {
          try {
            final rifle = rifles.firstWhere(
                  (r) => r.id == params.rifleId,
            );

            print('✅ Found rifle: ${rifle.name}');
            print('🔧 Current ammunition: ${rifle.ammunition?.name ?? 'None'}');

            Rifle updatedRifle;
            if (params.ammunition == null) {
              print('🗑️ Removing ammunition from rifle');
              updatedRifle = rifle.copyWith(ammunition: null, clearAmmunition: true);
            } else {
              print('🔄 Setting new ammunition: ${params.ammunition!.name}');
              updatedRifle = rifle.copyWith(ammunition: params.ammunition);
            }

            print('🔧 Updated rifle ammunition: ${updatedRifle.ammunition?.name ?? 'None'}');
            print('📤 Sending update to repository...');

            final result = await repository.updateRifle(updatedRifle);

            return result.fold(
                  (failure) {
                print('❌ Repository update failed: $failure');
                return Left(failure);
              },
                  (_) {
                print('✅ Repository update successful!');
                return const Right(null);
              },
            );

          } catch (e) {
            print('❌ Rifle not found with ID: ${params.rifleId}');
            return Left(DatabaseFailure('Rifle not found with ID: ${params.rifleId}'));
          }
        },
      );
    } catch (e) {
      print('❌ Unexpected error in UpdateRifleAmmunition: $e');
      return Left(DatabaseFailure('Failed to update rifle ammunition: $e'));
    }
  }
}