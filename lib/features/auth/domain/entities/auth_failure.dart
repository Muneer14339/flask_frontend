import 'package:equatable/equatable.dart';

abstract class AuthFailure extends Equatable {
  const AuthFailure();
}

class ServerFailure extends AuthFailure {
  final String message;

  const ServerFailure(this.message);

  @override
  List<Object> get props => [message];
}

class NetworkFailure extends AuthFailure {
  @override
  List<Object> get props => [];
}

class ValidationFailure extends AuthFailure {
  final String message;

  const ValidationFailure(this.message);

  @override
  List<Object> get props => [message];
}