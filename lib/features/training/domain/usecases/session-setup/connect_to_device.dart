import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../repositories/training_repository.dart';

class ConnectToDevice implements UseCase<void, ConnectToDeviceParams> {
  final TrainingRepository repository;

  ConnectToDevice(this.repository);

  @override
  Future<Either<Failure, void>> call(ConnectToDeviceParams params) async {
    return await repository.connectDevice(params.deviceId);
  }
}

class ConnectToDeviceParams extends Equatable {
  final String deviceId;

  const ConnectToDeviceParams({required this.deviceId});

  @override
  List<Object> get props => [deviceId];
}