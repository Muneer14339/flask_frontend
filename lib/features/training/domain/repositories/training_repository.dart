import 'package:dartz/dartz.dart';
import 'package:rt_tiltcant_accgyro/core/error/failures.dart';
import 'package:rt_tiltcant_accgyro/features/loadout/domain/entities/ammunition.dart';
import 'package:rt_tiltcant_accgyro/features/loadout/domain/entities/rifle.dart';
import 'package:rt_tiltcant_accgyro/features/loadout/domain/entities/scope.dart';
import '../entities/device_connection.dart';
import '../entities/session-setup/device_status.dart';
import '../entities/session-setup/loadout_selection.dart';
import '../entities/session-setup/training_preferences.dart';
import '../entities/session-setup/training_setup_status.dart';
import '../entities/training_session.dart';
import '../entities/angle_reading.dart';

abstract class TrainingRepository {
  Future<Either<Failure, DeviceConnection?>> getDeviceConnection();
  Future<Either<Failure, void>> connectDevice(String deviceId);
  Future<Either<Failure, void>> disconnectDevice();
  Future<Either<Failure, List<String>>> scanForDevices();

  Future<Either<Failure, TrainingSession>> startSession(TrainingSession session);
  Future<Either<Failure, TrainingSession>> endSession(String sessionId);
  Future<Either<Failure, TrainingSession?>> getActiveSession();

  Future<Either<Failure, void>> startMonitoring();
  Future<Either<Failure, void>> stopMonitoring();
  Future<Either<Failure, bool>> isMonitoring();

  Future<Either<Failure, AngleReading>> getCurrentReading();
  Stream<AngleReading> getRealtimeReadings();

  Future<Either<Failure, void>> calibrateSensors();


  // Training Setup Status
  Future<Either<Failure, TrainingSetupStatus>> getTrainingSetupStatus();
  Future<Either<Failure, void>> refreshSetupStatus();

  // Loadout Configuration
  Future<Either<Failure, List<Rifle>>> getAvailableRifles();
  Future<Either<Failure, List<Ammunition>>> getAvailableAmmunition();
  Future<Either<Failure, List<Scope>>> getAvailableScopes();
  Future<Either<Failure, LoadoutSelection>> getLoadoutSelection();
  Future<Either<Failure, void>> setActiveRifle(String rifleId);

  // Device Management
  Future<Either<Failure, DeviceStatus>> getDeviceStatus();

  // Training Preferences
  Future<Either<Failure, TrainingPreferences>> getTrainingPreferences();
  Future<Either<Failure, void>> saveTrainingPreferences(TrainingPreferences preferences);
  Future<Either<Failure, void>> testSound(String alertTone);

  // Settings Persistence
  Future<Either<Failure, void>> saveAllSettings();
}