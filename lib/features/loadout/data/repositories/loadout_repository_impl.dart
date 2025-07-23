import 'package:dartz/dartz.dart';
import 'dart:async';

import '../../../../core/error/failures.dart';
import '../../domain/entities/rifle.dart';
import '../../domain/entities/ammunition.dart';
import '../../domain/entities/scope.dart';
import '../../domain/entities/maintenance.dart';
import '../../domain/repositories/loadout_repository.dart';
import '../datasources/loadout_firebase_data_source.dart';
import '../models/rifle_model.dart';
import '../models/ammunition_model.dart';
import '../models/scope_model.dart';
import '../models/maintenance_model.dart';

class LoadoutFirebaseRepositoryImpl implements LoadoutRepository {
  final LoadoutFirebaseDataSource firebaseDataSource;

  LoadoutFirebaseRepositoryImpl({required this.firebaseDataSource});

  @override
  Future<Either<Failure, List<Rifle>>> getRifles() async {
    try {
      // Get current snapshot for immediate response
      final riflesSnapshot = await firebaseDataSource.getRiflesStream().first;
      final rifles = riflesSnapshot.map((model) => model.toEntity()).toList();
      return Right(rifles);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get rifles: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Ammunition>>> getAmmunition() async {
    try {
      final ammunitionSnapshot =
          await firebaseDataSource.getAmmunitionStream().first;
      final ammunition =
          ammunitionSnapshot.map((model) => model.toEntity()).toList();
      return Right(ammunition);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get ammunition: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Scope>>> getScopes() async {
    try {
      final scopesSnapshot = await firebaseDataSource.getScopesStream().first;
      final scopes = scopesSnapshot.map((model) => model.toEntity()).toList();
      return Right(scopes);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get scopes: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Maintenance>>> getMaintenance() async {
    try {
      final maintenanceSnapshot =
          await firebaseDataSource.getMaintenanceStream().first;
      final maintenance =
          maintenanceSnapshot.map((model) => model.toEntity()).toList();
      return Right(maintenance);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get maintenance: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addRifle(Rifle rifle) async {
    try {
      final model = RifleModel.fromEntity(rifle);
      await firebaseDataSource.addRifle(model);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add rifle: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addAmmunition(Ammunition ammunition) async {
    try {
      final model = AmmunitionModel.fromEntity(ammunition);
      await firebaseDataSource.addAmmunition(model);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add ammunition: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addScope(Scope scope) async {
    try {
      final model = ScopeModel.fromEntity(scope);
      await firebaseDataSource.addScope(model);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add scope: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addMaintenance(Maintenance maintenance) async {
    try {
      final model = MaintenanceModel.fromEntity(maintenance);
      await firebaseDataSource.addMaintenance(model);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add maintenance: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateRifle(Rifle rifle) async {
    try {
      final model = RifleModel.fromEntity(rifle);
      await firebaseDataSource.updateRifle(model);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update rifle: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateAmmunition(Ammunition ammunition) async {
    try {
      final model = AmmunitionModel.fromEntity(ammunition);
      await firebaseDataSource.updateAmmunition(model);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update ammunition: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateScope(Scope scope) async {
    try {
      final model = ScopeModel.fromEntity(scope);
      await firebaseDataSource.updateScope(model);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update scope: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAmmunition(String id) async {
    try {
      await firebaseDataSource.deleteAmmunition(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete ammunition: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> completeMaintenance(String id) async {
    try {
      await firebaseDataSource.completeMaintenance(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to complete maintenance: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setActiveRifle(String rifleId) async {
    try {
      await firebaseDataSource.setActiveRifle(rifleId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to set active rifle: $e'));
    }
  }

  @override
  Future<Either<Failure, Rifle?>> getActiveRifle() async {
    try {
      final activeRifleModel = await firebaseDataSource.getActiveRifle();
      final activeRifle = activeRifleModel?.toEntity();
      return Right(activeRifle);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get active rifle: $e'));
    }
  }

  // Stream methods for real-time updates
  Stream<Either<Failure, List<Rifle>>> getRiflesStream() {
    return firebaseDataSource.getRiflesStream().map((rifleModels) {
      try {
        final rifles = rifleModels.map((model) => model.toEntity()).toList();
        return Right<Failure, List<Rifle>>(rifles);
      } catch (e) {
        return Left<Failure, List<Rifle>>(
            DatabaseFailure('Failed to stream rifles: $e'));
      }
    }).handleError((error) {
      return Left<Failure, List<Rifle>>(
          DatabaseFailure('Stream error: $error'));
    });
  }

  Stream<Either<Failure, List<Ammunition>>> getAmmunitionStream() {
    return firebaseDataSource.getAmmunitionStream().map((ammunitionModels) {
      try {
        final ammunition =
            ammunitionModels.map((model) => model.toEntity()).toList();
        return Right<Failure, List<Ammunition>>(ammunition);
      } catch (e) {
        return Left<Failure, List<Ammunition>>(
            DatabaseFailure('Failed to stream ammunition: $e'));
      }
    }).handleError((error) {
      return Left<Failure, List<Ammunition>>(
          DatabaseFailure('Stream error: $error'));
    });
  }

  Stream<Either<Failure, List<Scope>>> getScopesStream() {
    return firebaseDataSource.getScopesStream().map((scopeModels) {
      try {
        final scopes = scopeModels.map((model) => model.toEntity()).toList();
        return Right<Failure, List<Scope>>(scopes);
      } catch (e) {
        return Left<Failure, List<Scope>>(
            DatabaseFailure('Failed to stream scopes: $e'));
      }
    }).handleError((error) {
      return Left<Failure, List<Scope>>(
          DatabaseFailure('Stream error: $error'));
    });
  }

  Stream<Either<Failure, List<Maintenance>>> getMaintenanceStream() {
    return firebaseDataSource.getMaintenanceStream().map((maintenanceModels) {
      try {
        final maintenance =
            maintenanceModels.map((model) => model.toEntity()).toList();
        return Right<Failure, List<Maintenance>>(maintenance);
      } catch (e) {
        return Left<Failure, List<Maintenance>>(
            DatabaseFailure('Failed to stream maintenance: $e'));
      }
    }).handleError((error) {
      return Left<Failure, List<Maintenance>>(
          DatabaseFailure('Stream error: $error'));
    });
  }

  @override
  Future<Either<Failure, void>> deleteMaintenance(String id) async {
    try {
      await firebaseDataSource.deleteMaintenance(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete maintenance: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteScope(String id) async {
    try {
      await firebaseDataSource.deleteScope(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete maintenance: $e'));
    }
  }
}
