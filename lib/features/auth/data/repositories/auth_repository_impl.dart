// // lib/features/auth/data/repositories/firebase_auth_repository_impl.dart
// import 'package:dartz/dartz.dart';
// import 'package:firebase_auth/firebase_auth.dart' as auth;
// import '../../domain/entities/auth_failure.dart';
// import '../../domain/entities/user_entity.dart';
// import '../../domain/repositories/auth_repository.dart';
// import '../datasources/firebase_auth_datasource.dart';
//
// class FirebaseAuthRepositoryImpl implements AuthRepository {
//   final FirebaseAuthDataSource firebaseDataSource;
//
//   FirebaseAuthRepositoryImpl(this.firebaseDataSource);
//
//   @override
//   Future<Either<AuthFailure, User>> signInWithGoogle() async {
//     try {
//       final user = await firebaseDataSource.signInWithGoogle();
//       return Right(user);
//     } on auth.FirebaseAuthException catch (e) {
//       return Left(_mapFirebaseException(e));
//     } catch (e) {
//       return Left(ServerFailure(e.toString()));
//     }
//   }
//
//   @override
//   Future<Either<AuthFailure, User>> login(String email, String password) async {
//     try {
//       final user = await firebaseDataSource.login(email, password);
//       return Right(user);
//     } on auth.FirebaseAuthException catch (e) {
//       return Left(_mapFirebaseException(e));
//     } catch (e) {
//       return Left(ServerFailure(e.toString()));
//     }
//   }
//
//   @override
//   Future<Either<AuthFailure, User>> signUp(String fullName, String email, String password) async {
//     try {
//       final user = await firebaseDataSource.signUp(fullName, email, password);
//       return Right(user);
//     } on auth.FirebaseAuthException catch (e) {
//       return Left(_mapFirebaseException(e));
//     } catch (e) {
//       return Left(ServerFailure(e.toString()));
//     }
//   }
//
//   @override
//   Future<Either<AuthFailure, bool>> forgotPassword(String email) async {
//     try {
//       final result = await firebaseDataSource.forgotPassword(email);
//       return Right(result);
//     } on auth.FirebaseAuthException catch (e) {
//       return Left(_mapFirebaseException(e));
//     } catch (e) {
//       return Left(ServerFailure(e.toString()));
//     }
//   }
//
//   @override
//   Future<Either<AuthFailure, bool>> verifyOtp(String otp) async {
//     try {
//       final result = await firebaseDataSource.verifyOtp(otp);
//       return Right(result);
//     } catch (e) {
//       return Left(ServerFailure(e.toString()));
//     }
//   }
//
//   @override
//   Future<Either<AuthFailure, void>> signOut() async {
//     try {
//       await firebaseDataSource.signOut();
//       return const Right(null);
//     } catch (e) {
//       return Left(ServerFailure(e.toString()));
//     }
//   }
//
//   @override
//   Future<Either<AuthFailure, User?>> getCurrentUser() async {
//     try {
//       final user = await firebaseDataSource.getCurrentUser();
//       return Right(user);
//     } catch (e) {
//       return Left(ServerFailure(e.toString()));
//     }
//   }
//
//   AuthFailure _mapFirebaseException(auth.FirebaseAuthException e) {
//     switch (e.code) {
//       case 'user-not-found':
//         return const ServerFailure('No user found with this email');
//       case 'wrong-password':
//         return const ServerFailure('Incorrect password');
//       case 'email-already-in-use':
//         return const ServerFailure('Email is already registered');
//       case 'weak-password':
//         return const ServerFailure('Password is too weak');
//       case 'invalid-email':
//         return const ValidationFailure('Invalid email address');
//       case 'user-disabled':
//         return const ServerFailure('User account has been disabled');
//       case 'too-many-requests':
//         return const ServerFailure('Too many attempts. Please try again later');
//       case 'account-exists-with-different-credential':
//         return const ServerFailure('Account exists with different sign-in method');
//       default:
//         return ServerFailure(e.message ?? 'Authentication failed');
//     }
//   }
// }