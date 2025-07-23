
// lib/features/loadout/data/repositories/ballistic_repository_impl.dart
import 'dart:math';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/ballistic_data.dart';
import '../../domain/repositories/ballistic_repository.dart';
import '../datasources/ballistic_firebase_data_source.dart';
import '../models/ballistic_models.dart';

class BallisticRepositoryImpl implements BallisticRepository {
  final BallisticFirebaseDataSource firebaseDataSource;

  BallisticRepositoryImpl({required this.firebaseDataSource});

  @override
  Future<Either<Failure, void>> saveDopeEntry(DopeEntry entry) async {
    try {
      final model = DopeEntryModel.fromEntity(entry);
      await firebaseDataSource.saveDopeEntry(model);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save DOPE entry: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DopeEntry>>> getDopeEntries(String rifleId) async {
    try {
      final models = await firebaseDataSource.getDopeEntries(rifleId);
      final entries = models.map((model) => model.toEntity()).toList();
      return Right(entries);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get DOPE entries: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDopeEntry(String entryId) async {
    try {
      await firebaseDataSource.deleteDopeEntry(entryId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete DOPE entry: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<DopeEntry>>>? getDopeEntriesStream(String rifleId) {
    return firebaseDataSource.getDopeEntriesStream(rifleId).map((models) {
      try {
        final entries = models.map((model) => model.toEntity()).toList();
        return Right<Failure, List<DopeEntry>>(entries);
      } catch (e) {
        return Left<Failure, List<DopeEntry>>(DatabaseFailure('Failed to stream DOPE entries: $e'));
      }
    });
  }

  @override
  Future<Either<Failure, void>> saveZeroEntry(ZeroEntry entry) async {
    try {
      final model = ZeroEntryModel.fromEntity(entry);
      await firebaseDataSource.saveZeroEntry(model);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save zero entry: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ZeroEntry>>> getZeroEntries(String rifleId) async {
    try {
      final models = await firebaseDataSource.getZeroEntries(rifleId);
      final entries = models.map((model) => model.toEntity()).toList();
      return Right(entries);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get zero entries: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteZeroEntry(String entryId) async {
    try {
      await firebaseDataSource.deleteZeroEntry(entryId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete zero entry: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<ZeroEntry>>>? getZeroEntriesStream(String rifleId) {
    return firebaseDataSource.getZeroEntriesStream(rifleId).map((models) {
      try {
        final entries = models.map((model) => model.toEntity()).toList();
        return Right<Failure, List<ZeroEntry>>(entries);
      } catch (e) {
        return Left<Failure, List<ZeroEntry>>(DatabaseFailure('Failed to stream zero entries: $e'));
      }
    });
  }

  @override
  Future<Either<Failure, void>> saveChronographData(ChronographData data) async {
    try {
      final model = ChronographDataModel.fromEntity(data);
      await firebaseDataSource.saveChronographData(model);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save chronograph data: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ChronographData>>> getChronographData(String rifleId) async {
    try {
      final models = await firebaseDataSource.getChronographData(rifleId);
      final data = models.map((model) => model.toEntity()).toList();
      return Right(data);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get chronograph data: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteChronographData(String dataId) async {
    try {
      await firebaseDataSource.deleteChronographData(dataId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete chronograph data: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<ChronographData>>>? getChronographDataStream(String rifleId) {
    return firebaseDataSource.getChronographDataStream(rifleId).map((models) {
      try {
        final data = models.map((model) => model.toEntity()).toList();
        return Right<Failure, List<ChronographData>>(data);
      } catch (e) {
        return Left<Failure, List<ChronographData>>(DatabaseFailure('Failed to stream chronograph data: $e'));
      }
    });
  }

  @override
  Future<Either<Failure, void>> saveBallisticCalculation(BallisticCalculation calculation) async {
    try {
      final model = BallisticCalculationModel.fromEntity(calculation);
      await firebaseDataSource.saveBallisticCalculation(model);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save ballistic calculation: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BallisticCalculation>>> getBallisticCalculations(String rifleId) async {
    try {
      final models = await firebaseDataSource.getBallisticCalculations(rifleId);
      final calculations = models.map((model) => model.toEntity()).toList();
      return Right(calculations);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get ballistic calculations: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBallisticCalculation(String calculationId) async {
    try {
      await firebaseDataSource.deleteBallisticCalculation(calculationId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete ballistic calculation: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<BallisticCalculation>>>? getBallisticCalculationsStream(String rifleId) {
    return firebaseDataSource.getBallisticCalculationsStream(rifleId).map((models) {
      try {
        final calculations = models.map((model) => model.toEntity()).toList();
        return Right<Failure, List<BallisticCalculation>>(calculations);
      } catch (e) {
        return Left<Failure, List<BallisticCalculation>>(DatabaseFailure('Failed to stream ballistic calculations: $e'));
      }
    });
  }

  @override
  Future<Either<Failure, List<BallisticPoint>>> calculateBallistics(
      double ballisticCoefficient,
      double muzzleVelocity,
      int targetDistance,
      double windSpeed,
      double windDirection,
      ) async {
    try {
      final List<BallisticPoint> trajectoryData = [];

      // Simplified ballistic calculation - for production use, consider using a proper ballistic library
      const double gravity = 32.174; // ft/s²
      const double airDensity = 0.0751; // lb/ft³ at sea level

      for (int range = 100; range <= targetDistance; range += 100) {
        // Calculate time of flight (simplified)
        final double timeOfFlight = (range * 3) / muzzleVelocity;

        // Calculate velocity at range (simplified drag model)
        final double dragCoefficient = 1 / ballisticCoefficient;
        final double velocity = muzzleVelocity * pow(0.95, range / 100); // Approximate velocity loss

        // Calculate drop (simplified)
        final double drop = 0.5 * gravity * timeOfFlight * timeOfFlight * 12; // Convert to inches

        // Calculate wind drift (simplified)
        final double windEffect = sin(windDirection * pi / 180) * windSpeed;
        final double windDrift = windEffect * timeOfFlight * 12 * 0.1; // Convert to inches

        // Calculate energy (simplified)
        final double bulletWeight = 140; // Assume 140gr bullet if not specified
        final double energy = (bulletWeight * velocity * velocity) / 450240; // ft-lbs

        trajectoryData.add(BallisticPoint(
          range: range,
          drop: drop,
          windDrift: windDrift,
          velocity: velocity,
          energy: energy,
          timeOfFlight: timeOfFlight,
        ));
      }

      return Right(trajectoryData);
    } catch (e) {
       return Left(DatabaseFailure('Failed to calculate ballistics: $e'));
    }
  }
}