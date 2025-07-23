// import 'package:dartz/dartz.dart';
//
// import '../../../../../core/error/failures.dart';
// import '../../../../../core/usecases/usecase.dart';
// import '../../entities/session-setup/available_device.dart';
// import '../../repositories/training_repository.dart';
//
//
// class ScanForDevices implements UseCase<List<AvailableDevice>, NoParams> {
//   final TrainingRepository repository;
//
//   ScanForDevices(this.repository);
//
//   @override
//   Future<Either<Failure, List<AvailableDevice>>> call(NoParams params) async {
//     return await repository.scanForDevices();
//   }
// }