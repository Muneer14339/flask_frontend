import 'package:dartz/dartz.dart';

import '../entities/auth_failure.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository repository;

  ForgotPasswordUseCase(this.repository);

  Future<Either<AuthFailure, bool>> call(String email) async {
    return await repository.forgotPassword(email);
  }
}
