// // lib/features/loadout/data/repositories/loadout_repository_impl.dart
// import 'package:dartz/dartz.dart';
// import 'dart:async';
//
// import '../../../../core/error/failures.dart';
// import '../../domain/entities/rifle.dart';
// import '../../domain/entities/ammunition.dart';
// import '../../domain/entities/scope.dart';
// import '../../domain/entities/maintenance.dart';
// import '../../domain/repositories/loadout_repository.dart';
// import '../datasources/loadout_http_data_source.dart';
// import '../models/rifle_model.dart';
// import '../models/ammunition_model.dart';
// import '../models/scope_model.dart';
// import '../models/maintenance_model.dart';
//
// class LoadoutRepositoryImpl implements LoadoutRepository {
//   final LoadoutHttpDataSource httpDataSource;
//
//   LoadoutRepositoryImpl({required this.httpDataSource});
//
//   @override
//   Future<Either<Failure, List<Rifle>>> getRifles() async {
//     try {
//       final rifleModels = await httpDataSource.getRifles();
//       final rifles = rifleModels.map((model) => model.toEntity()).toList();
//       return Right(rifles);
//     } catch (e) {
//       return Left(DatabaseFailure('Failed to get rifles: $e'));
//     }
//   }
//
//   @override
//   Future<Either<Failure, List<Ammunition>>> getAmmunition() async {
//     try {
//       final ammunitionModels = await httpDataSource.getAmmunition();
//       final ammunition = ammunitionModels.map((model) => model.toEntity()).toList();
//       return Right(ammunition);
//     } catch (e) {
//       return Left(DatabaseFailure('Failed to get ammunition: $e'));
//     }
//   }
//
//   @override
//   Future<Either<Failure, List<Scope>>> getScopes() async {
//     try {
//       final scopeModels = await httpDataSource.getScopes();
//       final scopes = scopeModels.map((model) => model.toEntity()).toList();
//       return Right(scopes);
//     } catch (e) {
//       return Left(DatabaseFailure('Failed to get scopes: $e'));
//     }
//   }
//
//   @override
//   Future<Either<Failure, List<Maintenance>>> getMaintenance() async {
//     try {
//       final maintenanceModels = await httpDataSource.getMaintenance();
//       final maintenance = maintenanceModels.map((model) => model.toEntity()).toList();
//       return Right(maintenance);
//     } catch (e) {
//       return Left(DatabaseFailure('Failed to get maintenance: $e'));
//     }
//   }
//
//   @override
//   Future<Either<Failure, void>> addRifle(Rifle rifle) async {
//     try {
//       final model = RifleModel.fromEntity(rifle);
//       await httpDataSource.addRifle(model);
//       return const Right(null);
//     } catch (e) {
//       return Left(DatabaseFailure('Failed to add rifle: $e'));
//     }
//   }
//
//   @override
//   Future<Either<Failure, void>> addAmmunition(Ammunition ammunition) async {
//     try {
//       final model = AmmunitionModel.fromEntity(ammunition);
//       await httpDataSource.addAmmunition(model);
//       return const Right(null);
//     } catch (e) {
//       return Left(DatabaseFailure('Failed to add ammunition: $e'));
//     }
//   }
//
//   @override
//   Future<Either<Failure, void>> addScope(Scope scope) async {
//     try {
//       final model = ScopeModel.fromEntity(scope);
//       await httpDataSource.addScope(model);
//       return const Right(null);
//     } catch (e) {
//       return Left(DatabaseFailure('Failed to add scope: $e'));
//     }
//   }
//
//   @override
//   Future<Either<Failure, void>> addMaintenance(Maintenance maintenance) async {
//     try {
//       final model = MaintenanceModel.fromEntity(maintenance);
//       await httpDataSource.addMaintenance(model);
//       return const Right(null);
//     } catch (e) {
//       return Left(DatabaseFailure('Failed to add maintenance: $e'));
//     }
//   }
//
//   @override
//   Future<Either<Failure, void>> updateRifle(Rifle rifle) async {
//     try {
//       final model = RifleModel.fromEntity(rifle);
//       await httpDataSource.updateRifle(model);
//       return const Right(null);
//     } catch (e) {
//       return Left(DatabaseFailure('Failed to update rifle: $e'));
//     }
//   }
//
//   @override
//   Future<Either<Failure, void>> updateAmmunition(Ammunition ammunition) async {
//     try {
//       final model = AmmunitionModel.fromEntity(ammunition);
//       await httpDataSource.updateAmmunition(model);
//       return const Right(null);
//     } catch (e) {
//       return Left(DatabaseFailure('Failed to update ammunition: $e'));
//     }
//   }
//
//   @override
//   Future<Either<Failure, void>> updateScope(Scope scope) async {
//     try {
//       final model = ScopeModel.fromEntity(scope);
//       await httpDataSource.updateScope(model);
//       return const Right(null);
//     } catch (e) {
//       return Left(DatabaseFailure('Failed to update scope: $e'));
//     }
//   }
//
//   @override
//   Future<Either<Failure, void>> deleteAmmunition(String id) async {
//     try {
//       await httpDataSource.deleteAmmunition(id);
//       return const Right(null);
//     } catch (e) {
//       return Left(DatabaseFailure('Failed to delete ammunition: $e'));
//     }
//   }
//
//   @override
//   Future<Either<Failure, void>> completeMaintenance(String id) async {
//     try {
//       await httpDataSource.completeMaintenance(id);
//       return const Right(null);
//     } catch (e) {
//       return Left(DatabaseFailure('Failed to complete maintenance: $e'));
//     }
//   }
//
//   @override
//   Future<Either<Failure, void>> setActiveRifle(String rifleId) async {
//     try {
//       await httpDataSource.setActiveRifle(rifleId);
//       return const Right(null);
//     } catch (e) {
//       return Left(DatabaseFailure('Failed to set active rifle: $e'));
//     }
//   }
//
//   @override
//   Future<Either<Failure, Rifle?>> getActiveRifle() async {
//     try {
//       final activeRifleModel = await httpDataSource.getActiveRifle();
//       final activeRifle = activeRifleModel?.toEntity();
//       return Right(activeRifle);
//     } catch (e) {
//       return Left(DatabaseFailure('Failed to get active rifle: $e'));
//     }
//   }
//
//   @override
//   Future<Either<Failure, void>> deleteMaintenance(String id) async {
//     try {
//       await httpDataSource.deleteMaintenance(id);
//       return const Right(null);
//     } catch (e) {
//       return Left(DatabaseFailure('Failed to delete maintenance: $e'));
//     }
//   }
//
//   @override
//   Future<Either<Failure, void>> deleteScope(String id) async {
//     try {
//       await httpDataSource.deleteScope(id);
//       return const Right(null);
//     } catch (e) {
//       return Left(DatabaseFailure('Failed to delete scope: $e'));
//     }
//   }
//
//   // Stream methods for real-time updates (HTTP polling)
//   @override
//   Stream<Either<Failure, List<Rifle>>> getRiflesStream() {
//     return httpDataSource.getRiflesStream().map((rifleModels) {
//       try {
//         final rifles = rifleModels.map((model) => model.toEntity()).toList();
//         return Right<Failure, List<Rifle>>(rifles);
//       } catch (e) {
//         return Left<Failure, List<Rifle>>(
//             DatabaseFailure('Failed to stream rifles: $e'));
//       }
//     }).handleError((error) {
//       return Left<Failure, List<Rifle>>(
//           DatabaseFailure('Stream error: $error'));
//     });
//   }
//
//   @override
//   Stream<Either<Failure, List<Ammunition>>> getAmmunitionStream() {
//     return httpDataSource.getAmmunitionStream().map((ammunitionModels) {
//       try {
//         final ammunition =
//         ammunitionModels.map((model) => model.toEntity()).toList();
//         return Right<Failure, List<Ammunition>>(ammunition);
//       } catch (e) {
//         return Left<Failure, List<Ammunition>>(
//             DatabaseFailure('Failed to stream ammunition: $e'));
//       }
//     }).handleError((error) {
//       return Left<Failure, List<Ammunition>>(
//           DatabaseFailure('Stream error: $error'));
//     });
//   }
//
//   @override
//   Stream<Either<Failure, List<Scope>>> getScopesStream() {
//     return httpDataSource.getScopesStream().map((scopeModels) {
//       try {
//         final scopes = scopeModels.map((model) => model.toEntity()).toList();
//         return Right<Failure, List<Scope>>(scopes);
//       } catch (e) {
//         return Left<Failure, List<Scope>>(
//             DatabaseFailure('Failed to stream scopes: $e'));
//       }
//     }).handleError((error) {
//       return Left<Failure, List<Scope>>(
//           DatabaseFailure('Stream error: $error'));
//     });
//   }
//
//   @override
//   Stream<Either<Failure, List<Maintenance>>> getMaintenanceStream() {
//     return httpDataSource.getMaintenanceStream().map((maintenanceModels) {
//       try {
//         final maintenance =
//         maintenanceModels.map((model) => model.toEntity()).toList();
//         return Right<Failure, List<Maintenance>>(maintenance);
//       } catch (e) {
//         return Left<Failure, List<Maintenance>>(
//             DatabaseFailure('Failed to stream maintenance: $e'));
//       }
//     }).handleError((error) {
//       return Left<Failure, List<Maintenance>>(
//           DatabaseFailure('Stream error: $error'));
//     });
//   }
// }