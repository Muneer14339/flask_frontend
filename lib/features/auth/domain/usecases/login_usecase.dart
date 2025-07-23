import 'package:dartz/dartz.dart';

import '../repositories/auth_repository.dart';
import '../entities/auth_failure.dart';
import '../entities/user_entity.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<AuthFailure, User>> call(String email, String password) async {
    return await repository.login(email, password);
  }
}