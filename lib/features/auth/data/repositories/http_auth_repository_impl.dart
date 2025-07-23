import 'package:dartz/dartz.dart';
import '../../domain/entities/auth_failure.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/http_auth_data_source.dart';

class HttpAuthRepositoryImpl implements AuthRepository {
  final HttpAuthDataSource httpDataSource;

  HttpAuthRepositoryImpl(this.httpDataSource);

  @override
  Future<Either<AuthFailure, User>> signInWithGoogle() async {
    try {
      final user = await httpDataSource.signInWithGoogle();
      return Right(user);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<AuthFailure, User>> login(String email, String password) async {
    try {
      final user = await httpDataSource.login(email, password);
      return Right(user);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<AuthFailure, User>> signUp(String fullName, String email, String password) async {
    try {
      final user = await httpDataSource.signUp(fullName, email, password);
      return Right(user);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<AuthFailure, bool>> forgotPassword(String email) async {
    try {
      final result = await httpDataSource.forgotPassword(email);
      return Right(result);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<AuthFailure, bool>> verifyOtp(String otp) async {
    try {
      // Note: You might need to store email locally or pass it differently
      // For now, this is a simplified implementation
      final result = await httpDataSource.verifyOtp('', otp);
      return Right(result);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<AuthFailure, void>> signOut() async {
    try {
      await httpDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<AuthFailure, User?>> getCurrentUser() async {
    try {
      final user = await httpDataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  AuthFailure _mapException(dynamic e) {
    final errorMessage = e.toString();

    // Map specific error messages to appropriate failure types
    if (errorMessage.contains('No user found with this email')) {
      return const ServerFailure('No user found with this email');
    } else if (errorMessage.contains('Incorrect password')) {
      return const ServerFailure('Incorrect password');
    } else if (errorMessage.contains('Email is already registered')) {
      return const ServerFailure('Email is already registered');
    } else if (errorMessage.contains('Password is too weak') ||
        errorMessage.contains('Password must')) {
      return const ServerFailure('Password is too weak');
    } else if (errorMessage.contains('Invalid email')) {
      return const ValidationFailure('Invalid email address');
    } else if (errorMessage.contains('User account has been disabled')) {
      return const ServerFailure('User account has been disabled');
    } else if (errorMessage.contains('Too many attempts') ||
        errorMessage.contains('too many requests')) {
      return const ServerFailure('Too many attempts. Please try again later');
    } else if (errorMessage.contains('Account exists with different')) {
      return const ServerFailure('Account exists with different sign-in method');
    } else if (errorMessage.contains('Connection') ||
        errorMessage.contains('Network') ||
        errorMessage.contains('timeout')) {
      return NetworkFailure();
    } else {
      // Extract the actual error message after "Exception: "
      String cleanMessage = errorMessage;
      if (errorMessage.startsWith('Exception: ')) {
        cleanMessage = errorMessage.substring(11);
      }
      return ServerFailure(cleanMessage);
    }
  }
}