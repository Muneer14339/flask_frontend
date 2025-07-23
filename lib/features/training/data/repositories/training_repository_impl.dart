import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../loadout/domain/entities/ammunition.dart';
import '../../../loadout/domain/entities/rifle.dart';
import '../../../loadout/domain/entities/scope.dart';
import '../../../loadout/domain/repositories/loadout_repository.dart';
import '../../domain/entities/device_connection.dart';
import '../../domain/entities/session-setup/device_status.dart';
import '../../domain/entities/session-setup/loadout_selection.dart';
import '../../domain/entities/session-setup/training_preferences.dart';
import '../../domain/entities/session-setup/training_setup_status.dart';
import '../../domain/entities/training_session.dart';
import '../../domain/entities/angle_reading.dart';
import '../../domain/repositories/training_repository.dart';
import '../datasources/ble_manager.dart';
import '../datasources/sensor_processor.dart';
import '../../services/audio_feedback_service.dart';

class RealTrainingRepository implements TrainingRepository {
  final BleManager _bleManager;
  final SensorProcessor _sensorProcessor;
  final AudioFeedbackService _audioFeedbackService; // ✅ Added audio service

  DeviceConnection? _connectedDevice;
  TrainingSession? _activeSession;
  bool _isMonitoring = false;
  StreamSubscription? _sensorSubscription;
  StreamController<AngleReading>? _readingsController;


  final LoadoutRepository loadoutRepository;

  // ✅ FIXED: In-memory storage with persistence-like behavior
  LoadoutSelection _loadoutSelection = const LoadoutSelection();
  TrainingPreferences _preferences = TrainingPreferences.defaults();

  // ✅ NEW: Cache for active rifle to persist across app sessions
  String? _cachedActiveRifleId;

  // ✅ Updated constructor to include audio service
  RealTrainingRepository(
      this._bleManager,
      this._sensorProcessor,
      this._audioFeedbackService,
      {required this.loadoutRepository});


  // ✅ NEW: Initialize active rifle from database on startup
  Future<void> _initializeActiveRifle() async {
    try {
      final activeRifleResult = await loadoutRepository.getActiveRifle();
      activeRifleResult.fold(
            (failure) => print("SettingsRepository: Failed to initialize active rifle"),
            (rifle) {
          if (rifle != null) {
            _cachedActiveRifleId = rifle.id;
            _loadoutSelection = _loadoutSelection.copyWith(activeRifleId: rifle.id);
            print("SettingsRepository: Initialized with active rifle: ${rifle.name} (${rifle.id})");
          }
        },
      );
    } catch (e) {
      print("SettingsRepository: Error initializing active rifle: $e");
    }
  }

  @override
  Future<Either<Failure, TrainingSetupStatus>> getTrainingSetupStatus() async {
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      // ✅ IMPROVED: Get real device connection status
      final deviceResult = await getDeviceConnection();
      final deviceConnected = deviceResult.fold(
            (failure) => false,
            (device) => device?.isConnected ?? false,
      );

      // ✅ FIXED: Always check current loadout status from repository
      await _refreshLoadoutSelection();
      final hasCompleteLoadout = _loadoutSelection.hasCompleteSetup;

      print("SettingsRepository: Training setup status - Device: $deviceConnected, Loadout: $hasCompleteLoadout, ActiveRifle: ${_loadoutSelection.activeRifleId}");

      return Right(TrainingSetupStatus(
        hasActiveLoadout: hasCompleteLoadout,
        hasDeviceConnected: deviceConnected,
        isTrainingReady: hasCompleteLoadout && deviceConnected,
        activeRifleId: _loadoutSelection.activeRifleId,
      ));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> refreshSetupStatus() async {
    await Future.delayed(const Duration(milliseconds: 100));

    // ✅ FIXED: Refresh loadout selection when status is refreshed
    await _refreshLoadoutSelection();

    return const Right(null);
  }

  @override
  Future<Either<Failure, List<Rifle>>> getAvailableRifles() async {
    return await loadoutRepository.getRifles();
  }

  @override
  Future<Either<Failure, List<Ammunition>>> getAvailableAmmunition() async {
    return await loadoutRepository.getAmmunition();
  }

  @override
  Future<Either<Failure, List<Scope>>> getAvailableScopes() async {
    return await loadoutRepository.getScopes();
  }

  @override
  Future<Either<Failure, LoadoutSelection>> getLoadoutSelection() async {
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      // ✅ FIXED: Always refresh loadout selection from repository
      await _refreshLoadoutSelection();

      print("SettingsRepository: getLoadoutSelection - returning: ${_loadoutSelection.activeRifleId}");
      return Right(_loadoutSelection);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  // ✅ NEW: Private method to refresh loadout selection from repository
  Future<void> _refreshLoadoutSelection() async {
    try {
      final activeRifleResult = await loadoutRepository.getActiveRifle();
      final activeRifle = activeRifleResult.fold(
            (failure) => null,
            (rifle) => rifle,
      );

      if (activeRifle != null) {
        _cachedActiveRifleId = activeRifle.id;
        _loadoutSelection = _loadoutSelection.copyWith(
          activeRifleId: activeRifle.id,
        );
        print("SettingsRepository: Refreshed loadout selection - Active rifle: ${activeRifle.name} (${activeRifle.id})");
      } else {
        // ✅ FIXED: If no active rifle found, clear the selection
        _cachedActiveRifleId = null;
        _loadoutSelection = _loadoutSelection.copyWith(clearRifle: true);
        print("SettingsRepository: No active rifle found - cleared selection");
      }
    } catch (e) {
      print("SettingsRepository: Error refreshing loadout selection: $e");
    }
  }

  @override
  Future<Either<Failure, void>> setActiveRifle(String rifleId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      print("SettingsRepository: Setting active rifle to: $rifleId");


      if (rifleId == '') {
        print("SettingsRepository: Rifle not found. Clearing active rifle.");

        _cachedActiveRifleId = null;
        _loadoutSelection = _loadoutSelection.copyWith(activeRifleId: null);

        return const Right(null);
      }

      // ✅ Update in loadout repository
      final result = await loadoutRepository.setActiveRifle(rifleId);

      return result.fold(
            (failure) {
          print("SettingsRepository: Failed to set active rifle in repository: $failure");
          return Left(failure);
        },
            (_) {
          // ✅ Update local state and cache
          _cachedActiveRifleId = rifleId;
          _loadoutSelection = _loadoutSelection.copyWith(activeRifleId: rifleId);

          print("SettingsRepository: Successfully set active rifle: $rifleId");
          return const Right(null);
        },
      );
    } catch (e) {
      print("SettingsRepository: Exception setting active rifle: $e");
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DeviceStatus>> getDeviceStatus() async {
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      // Get real device connection from training repository
      final deviceResult = await getDeviceConnection();

      return deviceResult.fold(
            (failure) => Left(failure),
            (device) {
          if (device == null) {
            return Right(DeviceStatus.disconnected());
          }

          return Right(DeviceStatus.connected(
            deviceId: device.deviceId,
            deviceName: device.deviceName,
            batteryLevel: device.batteryLevel,
            firmwareVersion: device.firmwareVersion,
            signalStrength: device.signalStrength,
          ));
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TrainingPreferences>> getTrainingPreferences() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return Right(_preferences);
  }

  @override
  Future<Either<Failure, void>> saveTrainingPreferences(TrainingPreferences preferences) async {
    await Future.delayed(const Duration(milliseconds: 200));

    try {

      final result = await saveTrainingPreferences(preferences);

      return result.fold(
            (failure) => Left(failure),
            (_) {
          _preferences = preferences;
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> testSound(String alertTone) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Here you could integrate with the actual audio system
    print('Testing sound: $alertTone');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> saveAllSettings() async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // ✅ FIXED: Save current active rifle state to ensure persistence
      if (_cachedActiveRifleId != null) {
        await loadoutRepository.setActiveRifle(_cachedActiveRifleId!);
      }

      // Save preferences to training repository


      final result = await saveTrainingPreferences(_preferences);

      return result.fold(
            (failure) => Left(failure),
            (_) {
          print('All settings saved successfully');
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  // ✅ NEW: Method to get current active rifle ID (for debugging/testing)
  String? get currentActiveRifleId => _cachedActiveRifleId;


















  @override
  Future<Either<Failure, DeviceConnection?>> getDeviceConnection() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Right(_connectedDevice);
  }

  @override
  Future<Either<Failure, void>> connectDevice(String deviceId) async {
    try {
      // Scan for devices using BleManager
      final scanResults = await _bleManager.scanForDevices(scanTimeoutSeconds: 15);

      // Find device with matching name/ID
      final targetDevice = scanResults.firstWhere(
            (result) => result.device.platformName == deviceId ||
            result.device.platformName.contains(deviceId),
        orElse: () => throw Exception('Device not found'),
      );

      // Connect to the device
      await _bleManager.connectToDevice(targetDevice.device);

      // Enable sensors after connection
      await _bleManager.enableSensors();

      final deviceInfo = await _bleManager.getDeviceInfo();

      // Create device connection object
      _connectedDevice = DeviceConnection(
        deviceId: deviceId,
        deviceName: targetDevice.device.platformName,
        isConnected: true,
        batteryLevel:  deviceInfo['batteryLevel'],
        firmwareVersion: deviceInfo['firmwareVersion'],
        signalStrength: deviceInfo['signalStrength'],
      );

      print("Real device connected: ${_connectedDevice?.deviceName}");
      return const Right(null);
    } catch (e) {
      print("Connection error: $e");
      return Left(DeviceConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, void>> disconnectDevice() async {
    try {
      // ✅ Stop audio feedback first
      _audioFeedbackService.setActive(false);

      await _bleManager.disconnect();
      _connectedDevice = null;
      _isMonitoring = false;

      // Clean up sensor subscription
      await _sensorSubscription?.cancel();
      _sensorSubscription = null;

      print("Device disconnected successfully");
      return const Right(null);
    } catch (e) {
      print("Disconnect error: $e");
      return Left(DeviceConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, List<String>>> scanForDevices() async {
    try {
      final scanResults = await _bleManager.scanForDevices(scanTimeoutSeconds: 10);

      final deviceNames = scanResults
          .map((result) => result.device.platformName)
          .where((name) => name.isNotEmpty)
          .toList();

      print("Found ${deviceNames.length} devices: $deviceNames");
      return Right(deviceNames);
    } catch (e) {
      print("Scan error: $e");
      return Left(DeviceConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, TrainingSession>> startSession(TrainingSession session) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _activeSession = session;
    print("Training session started: ${session.name}");
    return Right(session);
  }

  @override
  Future<Either<Failure, TrainingSession>> endSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (_activeSession?.id == sessionId) {
      final endedSession = TrainingSession(
        id: _activeSession!.id,
        name: _activeSession!.name,
        type: _activeSession!.type,
        notes: _activeSession!.notes,
        weather: _activeSession!.weather,
        windSpeed: _activeSession!.windSpeed,
        temperature: _activeSession!.temperature,
        humidity: _activeSession!.humidity,
        startTime: _activeSession!.startTime,
        endTime: DateTime.now(),
        readings: _activeSession!.readings,
        stats: _activeSession!.stats,
      );

      _activeSession = null;
      print("Training session ended: ${endedSession.name}");
      return Right(endedSession);
    }

    return Left(SessionFailure());
  }

  @override
  Future<Either<Failure, TrainingSession?>> getActiveSession() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return Right(_activeSession);
  }

  @override
  Future<Either<Failure, void>> startMonitoring() async {
    try {
      if (_connectedDevice?.isConnected != true) {
        return Left(DeviceConnectionFailure());
      }

      _isMonitoring = true;

      // Start listening to sensor data stream
      _startSensorDataStream();

      print("Real sensor monitoring started");
      return const Right(null);
    } catch (e) {
      print("Start monitoring error: $e");
      return Left(MonitoringFailure());
    }
  }

  // ✅ FIXED: Training Repository - stopMonitoring method

  @override
  Future<Either<Failure, void>> stopMonitoring() async {
    try {
      // ✅ Set monitoring flag to false FIRST
      _isMonitoring = false;

      // ✅ Stop audio feedback
      _audioFeedbackService.setActive(false);

      // ✅ Stop sensor data stream cleanly
      await _sensorSubscription?.cancel();
      _sensorSubscription = null;

      // ✅ Close readings controller
      await _readingsController?.close();
      _readingsController = null;

      print("Real sensor monitoring stopped (device remains connected)");

      // ✅ NOTE: Device remains connected (_connectedDevice is NOT cleared)
      // ✅ NOTE: BLE manager is NOT disconnected

      return const Right(null);
    } catch (e) {
      print("Stop monitoring error: $e");
      return Left(MonitoringFailure());
    }
  }

// ✅ UPDATED: _startSensorDataStream with cleaner stop detection
  void _startSensorDataStream() {
    print("Real sensor monitoring started");

    // Cancel any existing subscription
    _sensorSubscription?.cancel();

    // Variables for instant disconnect detection
    Timer? _dataTimeoutTimer;
    DateTime _lastDataReceived = DateTime.now();
    const Duration _dataTimeout = Duration(milliseconds: 500);

    try {
      // Listen to the BLE data stream and process it
      _sensorSubscription = _bleManager.dataStream.listen(
            (data) {
          // ✅ Only process if monitoring is active
          if (!_isMonitoring) {
            print("📴 Data received but monitoring stopped - ignoring");
            return;
          }

          _lastDataReceived = DateTime.now();

          // Cancel previous timeout timer
          _dataTimeoutTimer?.cancel();

          // Process raw data through sensor processor
          _sensorProcessor.processData(data);

          // Start new timeout timer for instant detection
          _dataTimeoutTimer = Timer(_dataTimeout, () {
            // ✅ Only handle timeout if still monitoring
            if (_isMonitoring) {
              print("⚠️ Data stream timeout detected - stopping audio and disconnecting");
              _handleDataStreamFailure();
            }
          });
        },
        onError: (error) {
          print("❌ Data stream error: $error");
          _dataTimeoutTimer?.cancel();

          // ✅ Only handle error if monitoring was active
          if (_isMonitoring) {
            _handleDataStreamFailure();
          } else {
            print("📴 Data stream error during stop - ignoring");
          }
        },
        onDone: () {
          print("🔌 Data stream ended");
          _dataTimeoutTimer?.cancel();

          // ✅ Only handle done if monitoring was active
          if (_isMonitoring) {
            _handleDataStreamFailure();
          } else {
            print("📴 Data stream ended during stop - ignoring");
          }
        },
      );

      // Listen to orientation updates from sensor processor
      _sensorSubscription = _sensorProcessor.orientationStream.listen(
            (orientation) {
          // ✅ Only emit readings if monitoring is active
          if (!_isMonitoring) {
            return;
          }

          // Convert orientation (roll, pitch) to AngleReading (cant, tilt)
          final angleReading = AngleReading(
            cant: double.parse((orientation.roll * 180 / 3.141592653589793).toStringAsFixed(1)),
            tilt: double.parse((orientation.pitch * 180 / 3.141592653589793).toStringAsFixed(1)),
            pan: 0.0,
            timestamp: DateTime.now(),
          );

          // Add to stream if monitoring is active and controller exists
          if (_isMonitoring && _readingsController != null && !_readingsController!.isClosed) {
            _readingsController!.add(angleReading);
          }
        },
        onError: (error) {
          print("❌ Orientation stream error: $error");
          if (_isMonitoring) {
            _handleDataStreamFailure();
          }
        },
        onDone: () {
          print("🔌 Orientation stream ended");
          if (_isMonitoring) {
            _handleDataStreamFailure();
          }
        },
      );

      // Additional periodic check for device connection status
      Timer.periodic(const Duration(milliseconds: 200), (timer) {
        // ✅ Stop timer if monitoring stopped
        if (!_isMonitoring) {
          timer.cancel();
          return;
        }

        // Check if BLE manager is still connected
        if (!_bleManager.isConnected) {
          print("🚫 BLE Manager shows device disconnected");
          timer.cancel();
          _handleDataStreamFailure();
          return;
        }

        // Check data freshness
        final timeSinceLastData = DateTime.now().difference(_lastDataReceived);
        if (timeSinceLastData > _dataTimeout) {
          print("⏰ Data too old (${timeSinceLastData.inMilliseconds}ms) - device likely disconnected");
          timer.cancel();
          _handleDataStreamFailure();
        }
      });

    } catch (e) {
      print("❌ Exception starting realtime readings: $e");
      _dataTimeoutTimer?.cancel();
      if (_isMonitoring) {
        _handleDataStreamFailure();
      }
    }
  }

  @override
  Future<Either<Failure, bool>> isMonitoring() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return Right(_isMonitoring);
  }

  @override
  Future<Either<Failure, AngleReading>> getCurrentReading() async {
    await Future.delayed(const Duration(milliseconds: 100));

    // Get current orientation from sensor processor
    final roll = _sensorProcessor.roll;
    final pitch = _sensorProcessor.pitch;

    final reading = AngleReading(
      cant: double.parse((roll * 180 / 3.141592653589793).toStringAsFixed(1)),
      tilt: double.parse((pitch * 180 / 3.141592653589793).toStringAsFixed(1)),
      pan: 0.0,
      timestamp: DateTime.now(),
    );

    return Right(reading);
  }

  @override
  Stream<AngleReading> getRealtimeReadings() {
    if (_readingsController == null) {
      _readingsController = StreamController<AngleReading>.broadcast();
    }
    return _readingsController!.stream;
  }

  // ✅ NEW: Handle data stream failures instantly
  void _handleDataStreamFailure() {
    print("🛑 Handling data stream failure - stopping audio and updating UI");

    // 1. INSTANTLY stop audio feedback
    try {
      _audioFeedbackService.setActive(false);
      _audioFeedbackService.stopAll();
    } catch (e) {
      print("⚠️ Error stopping audio: $e");
    }

    // 2. Update monitoring status
    _isMonitoring = false;

    // 3. Clear device connection
    _connectedDevice = null;

    // 4. Clean up streams
    _sensorSubscription?.cancel();
    _sensorSubscription = null;
    _readingsController?.close();
    _readingsController = null;

    // 5. Disconnect BLE manager
    try {
      _bleManager.disconnect();
    } catch (e) {
      print("⚠️ Error disconnecting BLE: $e");
    }

    print("✅ Data stream failure handled - audio stopped, device disconnected");
  }

  @override
  Future<Either<Failure, void>> calibrateSensors() async {
    try {
      if (_connectedDevice?.isConnected != true) {
        return Left(DeviceConnectionFailure());
      }

      // Reset sensor processor calibration
      _sensorProcessor.reset();

      // Wait for stabilization
      await Future.delayed(const Duration(seconds: 2));

      // Perform recalibration (set current position as zero)
      _sensorProcessor.recalibrate();

      print("Sensor calibration completed");
      return const Right(null);
    } catch (e) {
      print("Calibration error: $e");
      return Left(CalibrationFailure());
    }
  }





  // Cleanup method to be called when repository is disposed
  void dispose() {
    _audioFeedbackService.setActive(false); // ✅ Stop audio on dispose
    _sensorSubscription?.cancel();
    _readingsController?.close();
    _bleManager.disconnect();
    _sensorProcessor.dispose();
  }
}