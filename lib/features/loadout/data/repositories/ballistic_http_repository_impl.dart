// lib/features/loadout/data/repositories/ballistic_http_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/ballistic_data.dart';
import '../../domain/repositories/ballistic_repository.dart';
import '../datasources/ballistic_http_data_source.dart';
import '../models/ballistic_models.dart';

class BallisticHttpRepositoryImpl implements BallisticRepository {
  final BallisticHttpDataSource httpDataSource;

  BallisticHttpRepositoryImpl({required this.httpDataSource});

  @override
  Future<Either<Failure, void>> saveDopeEntry(DopeEntry entry) async {
    try {
      final model = DopeEntryModel.fromEntity(entry);
      await httpDataSource.saveDopeEntry(model);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save DOPE entry: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DopeEntry>>> getDopeEntries(String rifleId) async {
    try {
      final models = await httpDataSource.getDopeEntries(rifleId);
      final entries = models.map((model) => model.toEntity()).toList();
      return Right(entries);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get DOPE entries: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDopeEntry(String entryId) async {
    try {
      await httpDataSource.deleteDopeEntry(entryId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete DOPE entry: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<DopeEntry>>>? getDopeEntriesStream(String rifleId) {
    return httpDataSource.getDopeEntriesStream(rifleId).map((models) {
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
      await httpDataSource.saveZeroEntry(model);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save zero entry: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ZeroEntry>>> getZeroEntries(String rifleId) async {
    try {
      final models = await httpDataSource.getZeroEntries(rifleId);
      final entries = models.map((model) => model.toEntity()).toList();
      return Right(entries);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get zero entries: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteZeroEntry(String entryId) async {
    try {
      await httpDataSource.deleteZeroEntry(entryId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete zero entry: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<ZeroEntry>>>? getZeroEntriesStream(String rifleId) {
    return httpDataSource.getZeroEntriesStream(rifleId).map((models) {
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
      await httpDataSource.saveChronographData(model);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save chronograph data: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ChronographData>>> getChronographData(String rifleId) async {
    try {
      final models = await httpDataSource.getChronographData(rifleId);
      final data = models.map((model) => model.toEntity()).toList();
      return Right(data);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get chronograph data: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteChronographData(String dataId) async {
    try {
      await httpDataSource.deleteChronographData(dataId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete chronograph data: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<ChronographData>>>? getChronographDataStream(String rifleId) {
    return httpDataSource.getChronographDataStream(rifleId).map((models) {
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
      await httpDataSource.saveBallisticCalculation(model);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save ballistic calculation: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BallisticCalculation>>> getBallisticCalculations(String rifleId) async {
    try {
      final models = await httpDataSource.getBallisticCalculations(rifleId);
      final calculations = models.map((model) => model.toEntity()).toList();
      return Right(calculations);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get ballistic calculations: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBallisticCalculation(String calculationId) async {
    try {
      await httpDataSource.deleteBallisticCalculation(calculationId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete ballistic calculation: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<BallisticCalculation>>>? getBallisticCalculationsStream(String rifleId) {
    return httpDataSource.getBallisticCalculationsStream(rifleId).map((models) {
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
      final models = await httpDataSource.calculateBallistics(
        ballisticCoefficient,
        muzzleVelocity,
        targetDistance,
        windSpeed,
        windDirection,
      );

      final trajectoryData = models.map((model) => model.toEntity()).toList();
      return Right(trajectoryData);
    } catch (e) {
      return Left(DatabaseFailure('Failed to calculate ballistics: $e'));
    }
  }
}