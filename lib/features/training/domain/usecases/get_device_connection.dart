import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/device_connection.dart';
import '../repositories/training_repository.dart';

class GetDeviceConnection implements UseCase<DeviceConnection?, NoParams> {
  final TrainingRepository repository;

  GetDeviceConnection(this.repository);

  @override
  Future<Either<Failure, DeviceConnection?>> call(NoParams params) async {
    return await repository.getDeviceConnection();
  }
}