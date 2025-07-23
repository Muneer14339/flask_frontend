// import 'package:get_it/get_it.dart';
//
// import '../data/repositories/training_repository_impl.dart';
// import '../domain/usecases/get_device_connection.dart';
// import '../domain/repositories/training_repository.dart';
// import '../domain/usecases/connect_device.dart';
// import '../domain/usecases/start_session.dart';
// import '../domain/usecases/end_session.dart';
// import '../domain/usecases/start_monitoring.dart';
// import '../domain/usecases/stop_monitoring.dart';
// import '../domain/usecases/get_realtime_readings.dart';
// import '../domain/usecases/calibrate_sensors.dart';
// import '../presentation/bloc/training_bloc.dart';
//
// final sl = GetIt.instance;
//
// Future<void> initTrainingInjection() async {
//   // Repository
//   sl.registerLazySingleton<TrainingRepository>(
//         () => RealTrainingRepository(),
//   );
//
//   // Use cases
//   sl.registerLazySingleton(() => GetDeviceConnection(sl()));
//   sl.registerLazySingleton(() => ConnectDevice(sl()));
//   sl.registerLazySingleton(() => StartSession(sl()));
//   sl.registerLazySingleton(() => EndSession(sl()));
//   sl.registerLazySingleton(() => StartMonitoring(sl()));
//   sl.registerLazySingleton(() => StopMonitoring(sl()));
//   sl.registerLazySingleton(() => GetRealtimeReadings(sl()));
//   sl.registerLazySingleton(() => CalibrateSensors(sl()));
//
//   // BLoC
//   sl.registerFactory(() => TrainingBloc(
//     getDeviceConnection: sl(),
//     connectDevice: sl(),
//     startSession: sl(),
//     endSession: sl(),
//     startMonitoring: sl(),
//     stopMonitoring: sl(),
//     getRealtimeReadings: sl(),
//     calibrateSensors: sl(),
//   ));
// }