import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';
import '../entities/auth_failure.dart';
import '../entities/user_entity.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<Either<AuthFailure, User>> call(
      String fullName,
      String email,
      String password,
      ) async {
    return await repository.signUp(fullName, email, password);
  }
}