import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:rt_tiltcant_accgyro/core/error/failures.dart';
import 'package:rt_tiltcant_accgyro/core/usecases/usecase.dart';
import 'package:rt_tiltcant_accgyro/features/training/domain/repositories/training_repository.dart';

class SetActiveRifle implements UseCase<void, SetActiveRifleParams> {
  final TrainingRepository repository;

  SetActiveRifle(this.repository);

  @override
  Future<Either<Failure, void>> call(SetActiveRifleParams params) async {
    return await repository.setActiveRifle(params.rifleId);
  }
}

class SetActiveRifleParams extends Equatable {
  final String rifleId;

  const SetActiveRifleParams({required this.rifleId});

  @override
  List<Object> get props => [rifleId];
}
