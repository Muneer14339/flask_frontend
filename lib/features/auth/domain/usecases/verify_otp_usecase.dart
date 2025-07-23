import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';
import '../entities/auth_failure.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<Either<AuthFailure, bool>> call(String otp) async {
    return await repository.verifyOtp(otp);
  }
}