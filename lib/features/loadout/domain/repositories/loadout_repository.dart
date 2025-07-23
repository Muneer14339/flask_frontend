// lib/features/loadout/domain/repositories/loadout_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/rifle.dart';
import '../entities/ammunition.dart';
import '../entities/scope.dart';
import '../entities/maintenance.dart';

abstract class LoadoutRepository {
  // Basic CRUD operations
  Future<Either<Failure, List<Rifle>>> getRifles();
  Future<Either<Failure, List<Ammunition>>> getAmmunition();
  Future<Either<Failure, List<Scope>>> getScopes();
  Future<Either<Failure, List<Maintenance>>> getMaintenance();

  Future<Either<Failure, void>> addRifle(Rifle rifle);
  Future<Either<Failure, void>> addAmmunition(Ammunition ammunition);
  Future<Either<Failure, void>> addScope(Scope scope);
  Future<Either<Failure, void>> addMaintenance(Maintenance maintenance);

  Future<Either<Failure, void>> updateRifle(Rifle rifle);
  Future<Either<Failure, void>> updateAmmunition(Ammunition ammunition);
  Future<Either<Failure, void>> updateScope(Scope scope);
  Future<Either<Failure, void>> deleteAmmunition(String id);
  Future<Either<Failure, void>> completeMaintenance(String id);
  Future<Either<Failure, void>> deleteMaintenance(String id);
  Future<Either<Failure, void>> deleteScope(String id);


  Future<Either<Failure, void>> setActiveRifle(String rifleId);
  Future<Either<Failure, Rifle?>> getActiveRifle();

  // NEW: Stream methods for real-time updates (optional - only Firebase implementation provides these)
  Stream<Either<Failure, List<Rifle>>>? getRiflesStream() => null;
  Stream<Either<Failure, List<Ammunition>>>? getAmmunitionStream() => null;
  Stream<Either<Failure, List<Scope>>>? getScopesStream() => null;
  Stream<Either<Failure, List<Maintenance>>>? getMaintenanceStream() => null;
}
