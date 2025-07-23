// import 'package:dartz/dartz.dart';
// import '../../../../../core/error/failures.dart';
// import '../../../../../core/usecases/usecase.dart';
// import '../../entities/session-setup/training_setup_status.dart';
// import '../../repositories/training_repository.dart';
//
//
// class GetTrainingSetupStatus implements UseCase<TrainingSetupStatus, NoParams> {
//   final TrainingRepository repository;
//
//   GetTrainingSetupStatus(this.repository);
//
//   @override
//   Future<Either<Failure, TrainingSetupStatus>> call(NoParams params) async {
//     return await repository.getTrainingSetupStatus();
//   }
// }