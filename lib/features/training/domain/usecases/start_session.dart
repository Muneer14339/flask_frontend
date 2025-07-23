import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/training_session.dart';
import '../repositories/training_repository.dart';

class StartSession implements UseCase<TrainingSession, StartSessionParams> {
  final TrainingRepository repository;

  StartSession(this.repository);

  @override
  Future<Either<Failure, TrainingSession>> call(StartSessionParams params) async {
    return await repository.startSession(params.session);
  }
}

class StartSessionParams extends Equatable {
  final TrainingSession session;

  const StartSessionParams({required this.session});

  @override
  List<Object> get props => [session];
}
