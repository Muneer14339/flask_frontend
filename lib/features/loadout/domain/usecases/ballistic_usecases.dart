// lib/features/loadout/domain/usecases/ballistic_usecases.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ballistic_data.dart';
import '../repositories/ballistic_repository.dart';

// Save DOPE Entry Use Case
class SaveDopeEntry implements UseCase<void, DopeEntry> {
  final BallisticRepository repository;

  SaveDopeEntry(this.repository);

  @override
  Future<Either<Failure, void>> call(DopeEntry entry) async {
    return await repository.saveDopeEntry(entry);
  }
}

// Get DOPE Entries Use Case
class GetDopeEntries implements UseCase<List<DopeEntry>, String> {
  final BallisticRepository repository;

  GetDopeEntries(this.repository);

  @override
  Future<Either<Failure, List<DopeEntry>>> call(String rifleId) async {
    return await repository.getDopeEntries(rifleId);
  }
}

// Save Zero Entry Use Case
class SaveZeroEntry implements UseCase<void, ZeroEntry> {
  final BallisticRepository repository;

  SaveZeroEntry(this.repository);

  @override
  Future<Either<Failure, void>> call(ZeroEntry entry) async {
    return await repository.saveZeroEntry(entry);
  }
}

// Get Zero Entries Use Case
class GetZeroEntries implements UseCase<List<ZeroEntry>, String> {
  final BallisticRepository repository;

  GetZeroEntries(this.repository);

  @override
  Future<Either<Failure, List<ZeroEntry>>> call(String rifleId) async {
    return await repository.getZeroEntries(rifleId);
  }
}

// Save Chronograph Data Use Case
class SaveChronographData implements UseCase<void, ChronographData> {
  final BallisticRepository repository;

  SaveChronographData(this.repository);

  @override
  Future<Either<Failure, void>> call(ChronographData data) async {
    return await repository.saveChronographData(data);
  }
}

// Get Chronograph Data Use Case
class GetChronographData implements UseCase<List<ChronographData>, String> {
  final BallisticRepository repository;

  GetChronographData(this.repository);

  @override
  Future<Either<Failure, List<ChronographData>>> call(String rifleId) async {
    return await repository.getChronographData(rifleId);
  }
}

// Save Ballistic Calculation Use Case
class SaveBallisticCalculation implements UseCase<void, BallisticCalculation> {
  final BallisticRepository repository;

  SaveBallisticCalculation(this.repository);

  @override
  Future<Either<Failure, void>> call(BallisticCalculation calculation) async {
    return await repository.saveBallisticCalculation(calculation);
  }
}

// Get Ballistic Calculations Use Case
class GetBallisticCalculations implements UseCase<List<BallisticCalculation>, String> {
  final BallisticRepository repository;

  GetBallisticCalculations(this.repository);

  @override
  Future<Either<Failure, List<BallisticCalculation>>> call(String rifleId) async {
    return await repository.getBallisticCalculations(rifleId);
  }
}

// Calculate Ballistics Use Case
class CalculateBallisticsParams {
  final double ballisticCoefficient;
  final double muzzleVelocity;
  final int targetDistance;
  final double windSpeed;
  final double windDirection;

  CalculateBallisticsParams({
    required this.ballisticCoefficient,
    required this.muzzleVelocity,
    required this.targetDistance,
    required this.windSpeed,
    required this.windDirection,
  });
}

class CalculateBallistics implements UseCase<List<BallisticPoint>, CalculateBallisticsParams> {
  final BallisticRepository repository;

  CalculateBallistics(this.repository);

  @override
  Future<Either<Failure, List<BallisticPoint>>> call(CalculateBallisticsParams params) async {
    return await repository.calculateBallistics(
      params.ballisticCoefficient,
      params.muzzleVelocity,
      params.targetDistance,
      params.windSpeed,
      params.windDirection,
    );
  }
}

// Delete DOPE Entry Use Case
class DeleteDopeEntry implements UseCase<void, String> {
  final BallisticRepository repository;

  DeleteDopeEntry(this.repository);

  @override
  Future<Either<Failure, void>> call(String entryId) async {
    return await repository.deleteDopeEntry(entryId);
  }
}

// Delete Zero Entry Use Case
class DeleteZeroEntry implements UseCase<void, String> {
  final BallisticRepository repository;

  DeleteZeroEntry(this.repository);

  @override
  Future<Either<Failure, void>> call(String entryId) async {
    return await repository.deleteZeroEntry(entryId);
  }
}

// Delete Chronograph Data Use Case
class DeleteChronographData implements UseCase<void, String> {
  final BallisticRepository repository;

  DeleteChronographData(this.repository);

  @override
  Future<Either<Failure, void>> call(String dataId) async {
    return await repository.deleteChronographData(dataId);
  }
}

// Delete Ballistic Calculation Use Case
class DeleteBallisticCalculation implements UseCase<void, String> {
  final BallisticRepository repository;

  DeleteBallisticCalculation(this.repository);

  @override
  Future<Either<Failure, void>> call(String calculationId) async {
    return await repository.deleteBallisticCalculation(calculationId);
  }
}