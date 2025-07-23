import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../entities/session-setup/device_status.dart';
import '../../repositories/training_repository.dart';

class GetDeviceStatus implements UseCase<DeviceStatus, NoParams> {
  final TrainingRepository repository;

  GetDeviceStatus(this.repository);

  @override
  Future<Either<Failure, DeviceStatus>> call(NoParams params) async {
    return await repository.getDeviceStatus();
  }
}
