// lib/features/auth/domain/usecases/google_signin_usecase.dart
import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';
import '../entities/auth_failure.dart';
import '../entities/user_entity.dart';

class GoogleSignInUseCase {
  final AuthRepository repository;

  GoogleSignInUseCase(this.repository);

  Future<Either<AuthFailure, User>> call() async {
    return await repository.signInWithGoogle();
  }
}