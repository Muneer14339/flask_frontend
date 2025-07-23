import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/training_session.dart';
import '../repositories/training_repository.dart';

class EndSession implements UseCase<TrainingSession, EndSessionParams> {
  final TrainingRepository repository;

  EndSession(this.repository);

  @override
  Future<Either<Failure, TrainingSession>> call(EndSessionParams params) async {
    return await repository.endSession(params.sessionId);
  }
}

class EndSessionParams extends Equatable {
  final String sessionId;

  const EndSessionParams({required this.sessionId});

  @override
  List<Object> get props => [sessionId];
}