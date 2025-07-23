// import 'package:get_it/get_it.dart';
// import 'package:dio/dio.dart';
//
// import 'features/auth/data/datasources/auth_remote_datasource.dart';
// import 'features/auth/data/repositories/auth_repository_impl.dart';
// import 'features/auth/domain/repositories/auth_repository.dart';
// import 'features/auth/domain/usecases/forgot_password_usecase.dart';
// import 'features/auth/domain/usecases/login_usecase.dart';
// import 'features/auth/domain/usecases/signup_usecase.dart';
// import 'features/auth/domain/usecases/verify_otp_usecase.dart';
// import 'features/auth/presentation/bloc/auth_bloc.dart';
//
// import 'features/profile/data/datasources/profile_remote_data_source.dart';
// import 'features/profile/data/repositories/profile_repository_impl.dart';
// import 'features/profile/domain/repositories/profile_repository.dart';
// import 'features/profile/domain/usecases/get_profile_usecase.dart';
// import 'features/profile/domain/usecases/update_profile_usecase.dart';
// import 'features/profile/domain/usecases/change_password_usecase.dart';
// import 'features/profile/presentation/bloc/profile_bloc.dart';
//
// final sl = GetIt.instance;
//
// Future<void> init() async {
//   // BLoC
//   sl.registerFactory(
//         () => AuthBloc(
//       loginUseCase: sl(),
//       signUpUseCase: sl(),
//       forgotPasswordUseCase: sl(),
//       verifyOtpUseCase: sl(),
//     ),
//   );
//
//   sl.registerFactory(
//         () => ProfileBloc(
//       getProfileUseCase: sl(),
//       updateProfileUseCase: sl(),
//       changePasswordUseCase: sl(),
//     ),
//   );
//
//   // Auth Use cases
//   sl.registerLazySingleton(() => LoginUseCase(sl()));
//   sl.registerLazySingleton(() => SignUpUseCase(sl()));
//   sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
//   sl.registerLazySingleton(() => VerifyOtpUseCase(sl()));
//
//   // Profile Use cases
//   sl.registerLazySingleton(() => GetProfileUseCase(sl()));
//   sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
//   sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));
//
//   // Repository
//   sl.registerLazySingleton<AuthRepository>(
//         () => AuthRepositoryImpl(sl()),
//   );
//
//   sl.registerLazySingleton<ProfileRepository>(
//         () => ProfileRepositoryImpl(sl()),
//   );
//
//   // Data sources
//   sl.registerLazySingleton<AuthRemoteDataSource>(
//         () => AuthRemoteDataSourceImpl(sl()),
//   );
//
//   sl.registerLazySingleton<ProfileRemoteDataSource>(
//         () => ProfileRemoteDataSourceImpl(sl()),
//   );
//
//   // External
//   sl.registerLazySingleton(() => Dio());
// }