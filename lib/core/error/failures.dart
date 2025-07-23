// import 'package:equatable/equatable.dart';
//
// abstract class Failure extends Equatable {
//   @override
//   List<Object> get props => [];
// }
//
// class ServerFailure extends Failure {}
//
// class CacheFailure extends Failure {}
//
// class NetworkFailure extends Failure {}

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure();
}

class DatabaseFailure extends Failure {
  final String message;

  const DatabaseFailure(this.message);

  @override
  List<Object> get props => [message];
}

class ValidationFailure extends Failure {
  final String message;

  const ValidationFailure(this.message);

  @override
  List<Object> get props => [message];
}
class ServerFailure extends Failure {
  final String message;

  const ServerFailure(this.message);

  @override
  List<Object> get props => [message];
}
// Training specific failures
class DeviceConnectionFailure extends Failure {
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

class CalibrationFailure extends Failure {
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

class SessionFailure extends Failure {
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

class MonitoringFailure extends Failure {
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}