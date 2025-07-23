// lib/features/loadout/domain/repositories/ballistic_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/ballistic_data.dart';

abstract class BallisticRepository {
  // DOPE Card operations
  Future<Either<Failure, void>> saveDopeEntry(DopeEntry entry);
  Future<Either<Failure, List<DopeEntry>>> getDopeEntries(String rifleId);
  Future<Either<Failure, void>> deleteDopeEntry(String entryId);
  Stream<Either<Failure, List<DopeEntry>>>? getDopeEntriesStream(String rifleId);

  // Zero tracking operations
  Future<Either<Failure, void>> saveZeroEntry(ZeroEntry entry);
  Future<Either<Failure, List<ZeroEntry>>> getZeroEntries(String rifleId);
  Future<Either<Failure, void>> deleteZeroEntry(String entryId);
  Stream<Either<Failure, List<ZeroEntry>>>? getZeroEntriesStream(String rifleId);

  // Chronograph data operations
  Future<Either<Failure, void>> saveChronographData(ChronographData data);
  Future<Either<Failure, List<ChronographData>>> getChronographData(String rifleId);
  Future<Either<Failure, void>> deleteChronographData(String dataId);
  Stream<Either<Failure, List<ChronographData>>>? getChronographDataStream(String rifleId);

  // Ballistic calculation operations
  Future<Either<Failure, void>> saveBallisticCalculation(BallisticCalculation calculation);
  Future<Either<Failure, List<BallisticCalculation>>> getBallisticCalculations(String rifleId);
  Future<Either<Failure, void>> deleteBallisticCalculation(String calculationId);
  Stream<Either<Failure, List<BallisticCalculation>>>? getBallisticCalculationsStream(String rifleId);

  // Ballistic calculator
  Future<Either<Failure, List<BallisticPoint>>> calculateBallistics(
      double ballisticCoefficient,
      double muzzleVelocity,
      int targetDistance,
      double windSpeed,
      double windDirection,
      );
}
