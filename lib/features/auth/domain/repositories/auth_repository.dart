// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/auth_failure.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<AuthFailure, User>> login(String email, String password);
  Future<Either<AuthFailure, User>> signUp(String fullName, String email, String password);
  Future<Either<AuthFailure, User>> signInWithGoogle();
  Future<Either<AuthFailure, bool>> forgotPassword(String email);
  Future<Either<AuthFailure, bool>> verifyOtp(String otp);
  Future<Either<AuthFailure, void>> signOut();
  Future<Either<AuthFailure, User?>> getCurrentUser();
}