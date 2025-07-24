// lib/main.dart - Updated without Settings dependencies
import 'package:http/http.dart' as http;

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rt_tiltcant_accgyro/features/loadout/domain/usecases/delete_maintenance.dart';
import 'package:rt_tiltcant_accgyro/features/loadout/domain/usecases/delete_scope.dart';

import 'core/navigation/main_tab_container.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';

// Auth HTTP imports (replacing Firebase)
import 'core/utiles/cubits/validator_cubit.dart';
import 'features/auth/data/datasources/http_auth_data_source.dart';
import 'features/auth/data/repositories/http_auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/forgot_password_usecase.dart';
import 'features/auth/domain/usecases/google_signin_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/signup_usecase.dart';
import 'features/auth/domain/usecases/verify_otp_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/reset_password_screen.dart';
import 'features/auth/presentation/screens/signup_screen.dart';
import 'features/auth/presentation/screens/verify_otp_screen.dart';


// Loadout Firebase imports
import 'features/loadout/data/datasources/ballistic_firebase_data_source.dart';
import 'features/loadout/data/datasources/ballistic_http_data_source.dart';
import 'features/loadout/data/datasources/loadout_http_data_source.dart';
import 'features/loadout/data/repositories/ballistic_repository_impl.dart';
import 'features/loadout/data/repositories/loadout_repository_impl.dart';
import 'features/loadout/domain/repositories/ballistic_repository.dart';
import 'features/loadout/domain/repositories/loadout_repository.dart';
import 'features/loadout/domain/usecases/ballistic_usecases.dart';
import 'features/loadout/domain/usecases/set_active_rifle.dart';
import 'features/training/domain/usecases/session-setup/set_active_Loadout.dart' as loadout_usecases;

// Training imports
import 'features/loadout/data/datasources/loadout_firebase_data_source.dart';
import 'features/loadout/domain/usecases/add_ammunition.dart';
import 'features/loadout/domain/usecases/add_maintenance.dart';
import 'features/loadout/domain/usecases/add_rifle.dart';
import 'features/loadout/domain/usecases/add_scope.dart';
import 'features/loadout/domain/usecases/complete_maintenance.dart';
import 'features/loadout/domain/usecases/delete_ammunition.dart';
import 'features/loadout/domain/usecases/get_ammunition.dart';
import 'features/loadout/domain/usecases/get_maintenance.dart';
import 'features/loadout/domain/usecases/get_rifles.dart';
import 'features/loadout/domain/usecases/get_scopes.dart';
import 'features/loadout/domain/usecases/update_ammunition.dart';
import 'features/loadout/domain/usecases/update_rifle.dart';
import 'features/loadout/domain/usecases/update_rifle_ammunition.dart';
import 'features/loadout/domain/usecases/update_rifle_scope.dart';
import 'features/loadout/domain/usecases/update_scope.dart';
import 'features/loadout/presentation/bloc/ballistic_bloc.dart';
import 'features/loadout/presentation/bloc/loadout_bloc.dart';
import 'features/training/data/datasources/ble_manager.dart';
import 'features/training/data/datasources/sensor_processor.dart';
import 'features/training/data/repositories/training_repository_impl.dart';
import 'features/training/domain/repositories/training_repository.dart';
import 'features/training/domain/usecases/connect_device.dart';
import 'features/training/domain/usecases/get_device_connection.dart';
import 'features/training/domain/usecases/start_session.dart';
import 'features/training/domain/usecases/end_session.dart';
import 'features/training/domain/usecases/start_monitoring.dart';
import 'features/training/domain/usecases/stop_monitoring.dart';
import 'features/training/domain/usecases/get_realtime_readings.dart';
import 'features/training/domain/usecases/calibrate_sensors.dart';
import 'features/training/presentation/bloc/training_bloc.dart';
import 'features/training/presentation/bloc/training_event.dart';
import 'features/training/services/audio_feedback_service.dart';
import 'features/training/services/permission_service.dart';
import 'firebase_options.dart';

final sl = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('🔥 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');

    print('🚀 Starting RifleAxis App with Firebase Integration...');

    // Setup dependency injection
    await setupLocator();

    runApp(const MyApp());
  } catch (e) {
    print('❌ Error initializing app: $e');
    runApp(const ErrorApp());
  }
}

Future<void> setupLocator() async {
  try {
    print('🔧 Setting up dependency injection...');

    // ✅ NEW: HTTP Client Setup (replacing Firebase Auth)
    await _setupHttpAuthDependencies();

    // ✅ KEEPING: Loadout Firebase dependencies (unchanged)
    await _setupLoadoutFirebaseDependencies();


    // ✅ KEEPING: Training dependencies (unchanged)
    await _setupTrainingDependencies();

    print('✅ Dependency injection setup completed');
  } catch (e) {
    print('❌ Error setting up dependency injection: $e');
    rethrow;
  }
}


Future<void> _setupHttpAuthDependencies() async {
  print('🌐 Setting up HTTP Auth dependencies...');

  // HTTP Client (Dio)
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio();

    // Configure base options
    dio.options.baseUrl = 'http://192.168.1.248:5000/api'; // 🔧 CHANGE THIS TO YOUR BACKEND URL
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);

    // Add logging interceptor for debugging
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
      ));
    }

    return dio;
  });

  // Google Sign In
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn(
      scopes: ['email', 'profile'],
      // Add your Google Client ID here for better security
      // clientId: 'your-google-client-id.apps.googleusercontent.com',
      clientId: "134573180968-dr8bcrgrua24vlvvf4meo81jm7e13rhs.apps.googleusercontent.com"
  ));

  // HTTP Auth Data Source
  sl.registerLazySingleton<HttpAuthDataSource>(
        () => HttpAuthDataSourceImpl(
      dio: sl(),
      googleSignIn: sl(),
    ),
  );

  // Auth Repository (using HTTP instead of Firebase)
  sl.registerLazySingleton<AuthRepository>(
        () => HttpAuthRepositoryImpl(sl()),
  );

  // Auth Use Cases (unchanged)
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => GoogleSignInUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl()));

  // AutoValidationCubit
  sl.registerFactory(() => AutoValidationCubit());

  // Auth BLoC (unchanged)
  sl.registerFactory(() => AuthBloc(
    loginUseCase: sl(),
    signUpUseCase: sl(),
    googleSignInUseCase: sl(),
    forgotPasswordUseCase: sl(),
    verifyOtpUseCase: sl(),
  ));

  print('✅ HTTP Auth dependencies setup complete');
}

Future<void> _setupLoadoutFirebaseDependencies() async {
  print('🔥 Setting up Firebase Loadout dependencies...');
// Core dependencies
  sl.registerLazySingleton<http.Client>(() => http.Client());
  String getToken() {
    final authService = sl<HttpAuthDataSource>();
    return authService.getToken() ?? '';
  }



  // Backend URL configuration
  const String baseUrl = 'http://192.168.1.248:5000'; // Your backend URL
  // Firebase Data Source
  sl.registerLazySingleton<LoadoutHttpDataSource>(
        () => LoadoutHttpDataSourceImpl(
      httpClient: sl<http.Client>(),
      baseUrl: baseUrl,
      getToken: getToken,
    ),
  );

  // ✅ ADD: Ballistic Firebase Data Source
  sl.registerLazySingleton<BallisticHttpDataSource>(
        () => BallisticHttpDataSourceImpl(
      httpClient: sl<http.Client>(),
      baseUrl: baseUrl,
      getToken: getToken,
    ),
  );


  // Firebase Repository
  sl.registerLazySingleton<LoadoutRepository>(
        () => LoadoutRepositoryImpl(
      httpDataSource: sl<LoadoutHttpDataSource>(),
    ),
  );

  // ✅ ADD: Ballistic Repository
  sl.registerLazySingleton<BallisticRepository>(
        () => BallisticRepositoryImpl(
      httpDataSource: sl<BallisticHttpDataSource>(),
    ),
  );

  // Also register as Firebase repository for BLoC
  sl.registerLazySingleton<LoadoutRepositoryImpl>(
        () => sl<LoadoutRepository>() as LoadoutRepositoryImpl,
  );

  // ✅ ADD: Ballistic Repository Impl for BLoC
  sl.registerLazySingleton<BallisticRepositoryImpl>(
        () => sl<BallisticRepository>() as BallisticRepositoryImpl,
  );

  // Loadout Use cases (existing)
  sl.registerLazySingleton(() => GetRifles(sl()));
  sl.registerLazySingleton(() => GetAmmunition(sl()));
  sl.registerLazySingleton(() => GetScopes(sl()));
  sl.registerLazySingleton(() => GetMaintenance(sl()));
  sl.registerLazySingleton(() => AddRifle(sl()));
  sl.registerLazySingleton(() => AddAmmunition(sl()));
  sl.registerLazySingleton(() => AddScope(sl()));
  sl.registerLazySingleton(() => AddMaintenance(sl()));
  sl.registerLazySingleton(() => SetActiveRifle(sl()));
  sl.registerLazySingleton(() => DeleteAmmunition(sl()));
  sl.registerLazySingleton(() => CompleteMaintenance(sl()));
  sl.registerLazySingleton(() => DeleteMaintenance(sl()));
  sl.registerLazySingleton(() => DeleteScope(sl()));
  sl.registerLazySingleton(() => UpdateRifleScope(sl()));
  sl.registerLazySingleton(() => UpdateRifleAmmunition(sl()));
  sl.registerLazySingleton(() => UpdateRifle(sl()));
  sl.registerLazySingleton(() => UpdateScope(sl()));
  sl.registerLazySingleton(() => UpdateAmmunition(sl()));

  // ✅ ADD: Ballistic Use Cases
  sl.registerLazySingleton(() => SaveDopeEntry(sl()));
  sl.registerLazySingleton(() => GetDopeEntries(sl()));
  sl.registerLazySingleton(() => DeleteDopeEntry(sl()));
  sl.registerLazySingleton(() => SaveZeroEntry(sl()));
  sl.registerLazySingleton(() => GetZeroEntries(sl()));
  sl.registerLazySingleton(() => DeleteZeroEntry(sl()));
  sl.registerLazySingleton(() => SaveChronographData(sl()));
  sl.registerLazySingleton(() => GetChronographData(sl()));
  sl.registerLazySingleton(() => DeleteChronographData(sl()));
  sl.registerLazySingleton(() => SaveBallisticCalculation(sl()));
  sl.registerLazySingleton(() => GetBallisticCalculations(sl()));
  sl.registerLazySingleton(() => DeleteBallisticCalculation(sl()));
  sl.registerLazySingleton(() => CalculateBallistics(sl()));

  // Loadout BLoC with Firebase repository (existing)
  sl.registerFactory(() => LoadoutBloc(
    getRifles: sl(),
    getAmmunition: sl(),
    getScopes: sl(),
    getMaintenance: sl(),
    addRifle: sl(),
    addAmmunition: sl(),
    addScope: sl(),
    addMaintenance: sl(),
    deleteAmmunition: sl(),
    completeMaintenance: sl(),
    deleteScope: sl(),
    deleteMaintenance: sl(),
    updateRifleScope: sl(),
    updateRifleAmmunition: sl(),
    updateRifle: sl(),
    updateScope: sl(),
    updateAmmunition: sl(), httpRepository: sl(),
  ));

  // ✅ ADD: Ballistic BLoC
  sl.registerFactory(() => BallisticBloc(
    saveDopeEntry: sl(),
    getDopeEntries: sl(),
    deleteDopeEntry: sl(),
    saveZeroEntry: sl(),
    getZeroEntries: sl(),
    deleteZeroEntry: sl(),
    saveChronographData: sl(),
    getChronographData: sl(),
    deleteChronographData: sl(),
    saveBallisticCalculation: sl(),
    getBallisticCalculations: sl(),
    deleteBallisticCalculation: sl(),
    calculateBallistics: sl(),
    ballisticRepository: sl(),
  ));

  print('✅ Firebase Loadout dependencies setup complete');
}

Future<void> _setupTrainingDependencies() async {
  print('🎯 Setting up Training dependencies...');

  // Hardware Components
  sl.registerLazySingleton(() => BleManager());
  sl.registerLazySingleton(() => SensorProcessor());

  // Permission Service
  sl.registerLazySingleton(() => PermissionService());

  // Audio Feedback Service
  sl.registerLazySingleton(() => AudioFeedbackService());

  // Repository (Data Layer)
  sl.registerLazySingleton<TrainingRepository>(
        () => RealTrainingRepository(sl(), sl(), sl(), loadoutRepository: sl()),
  );

  // Use Cases (Domain Layer)
  sl.registerLazySingleton(() => GetDeviceConnection(sl()));
  sl.registerLazySingleton(() => ConnectDevice(sl()));
  sl.registerLazySingleton(() => StartSession(sl()));
  sl.registerLazySingleton(() => EndSession(sl()));
  sl.registerLazySingleton(() => StartMonitoring(sl()));
  sl.registerLazySingleton(() => StopMonitoring(sl()));
  sl.registerLazySingleton(() => GetRealtimeReadings(sl()));
  sl.registerLazySingleton(() => CalibrateSensors(sl()));
  sl.registerLazySingleton(() => loadout_usecases.SetActiveRifle(sl()));

  // ✅ UPDATED: Single Training BLoC with all functionality
  sl.registerFactory(() => TrainingBloc(
    getDeviceConnection: sl(),
    connectDevice: sl(),
    startSession: sl(),
    endSession: sl(),
    startMonitoring: sl(),
    stopMonitoring: sl(),
    getRealtimeReadings: sl(),
    calibrateSensors: sl(),
    trainingRepository: sl(),
    audioFeedbackService: sl(),
    // ✅ NEW: Loadout use cases for settings functionality
    getRifles: sl(),
    getAmmunition: sl(),
    getScopes: sl(),
    setActiveRifle: sl(),
  ));

  print('✅ Training dependencies setup complete');
}

// BLoC initialization helper
class BlocInitializer extends StatelessWidget {
  final Widget child;

  const BlocInitializer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeBlocs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return child;
        }
        return MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            backgroundColor: AppTheme.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Initializing Firebase...',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _initializeBlocs() async {
    try {
      // Initialize TrainingBloc
      final trainingBloc = sl<TrainingBloc>();
      trainingBloc.add(LoadTrainingData());

      // Small delay for initialization
      await Future.delayed(const Duration(milliseconds: 500));
      print('✅ BLoCs initialized successfully');
    } catch (e) {
      print('❌ Error initializing BLoCs: $e');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocInitializer(
      child: MultiBlocProvider(
        providers: [
          // ✅ ADD: AutoValidationCubit Provider
          BlocProvider<AutoValidationCubit>(
            create: (context) => sl<AutoValidationCubit>(),
          ),
          // Auth BLoC
          BlocProvider<AuthBloc>(
            create: (context) => sl<AuthBloc>(),
          ),
          // Loadout BLoC with Firebase
          BlocProvider<LoadoutBloc>(
            create: (context) => sl<LoadoutBloc>(),
          ),
          // ✅ ADD: Ballistic BLoC
          BlocProvider<BallisticBloc>(
            create: (context) => sl<BallisticBloc>(),
          ),
          // ✅ UPDATED: Single Training BLoC (Settings removed)
          BlocProvider<TrainingBloc>(
            create: (context) => sl<TrainingBloc>(),
          ),
        ],
        child: MaterialApp(
          title: 'RifleAxis',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          home: const AuthWrapper(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/verify-otp': (context) => const VerifyOtpScreen(),
            '/reset-password': (context) => const ResetPasswordScreen(),

            // ✅ UPDATED: Use MainTabContainer for tab navigation
            '/main': (context) => const MainTabContainer(initialIndex: 1), // Default to Loadout
            '/home': (context) => const MainTabContainer(initialIndex: 0),
            '/Loadout': (context) => const MainTabContainer(initialIndex: 1),
            '/train': (context) => const MainTabContainer(initialIndex: 2),
            '/history': (context) => const MainTabContainer(initialIndex: 3),
            '/profile': (context) => const MainTabContainer(initialIndex: 4),
            // ✅ REMOVED: '/settings' route (no longer needed)
          },
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) =>
              const MainTabContainer(initialIndex: 1),
            );
          },
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Checking authentication...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is signed in, go to Loadout page
          return const MainTabContainer(initialIndex: 1);
        }

        // User is not signed in, show login screen
        return const LoginScreen();
      },
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RifleAxis - Error',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: AppTheme.danger,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.danger,
              ),
              SizedBox(height: 16),
              Text(
                'Failed to Initialize App',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.danger,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please check your internet connection and restart',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/Loadout');
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getPageIcon(),
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              '$title Page',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Coming Soon!',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/Loadout'),
              icon: const Icon(Icons.settings),
              label: const Text('Back to Loadout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPageIcon() {
    switch (title.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'train':
        return Icons.gps_fixed;
      case 'history':
        return Icons.bar_chart;
      case 'profile':
        return Icons.person;
      default:
        return Icons.construction;
    }
  }

  int _getCurrentIndex() {
    switch (title.toLowerCase()) {
      case 'home':
        return 0;
      case 'train':
        return 2;
      case 'history':
        return 3;
      case 'profile':
        return 4;
      default:
        return 0;
    }
  }
}