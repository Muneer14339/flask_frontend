import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/training_repository.dart';

class ConnectDevice implements UseCase<void, ConnectDeviceParams> {
  final TrainingRepository repository;

  ConnectDevice(this.repository);

  @override
  Future<Either<Failure, void>> call(ConnectDeviceParams params) async {
    return await repository.connectDevice(params.deviceId);
  }
}

class ConnectDeviceParams extends Equatable {
  final String deviceId;

  const ConnectDeviceParams({required this.deviceId});

  @override
  List<Object> get props => [deviceId];
}
