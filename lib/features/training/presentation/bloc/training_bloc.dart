// lib/features/training/presentation/bloc/training_bloc.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/session-setup/session_information.dart';
import '../../domain/entities/training_session.dart';
import '../../domain/entities/angle_reading.dart';
import '../../domain/entities/position_preset.dart';
import '../../domain/entities/session_stats.dart';
import '../../domain/usecases/get_device_connection.dart';
import '../../domain/usecases/connect_device.dart';
import '../../domain/usecases/start_session.dart';
import '../../domain/usecases/end_session.dart';
import '../../domain/usecases/start_monitoring.dart';
import '../../domain/usecases/stop_monitoring.dart';
import '../../domain/usecases/get_realtime_readings.dart';
import '../../domain/usecases/calibrate_sensors.dart';
import '../../domain/repositories/training_repository.dart';
import '../../services/audio_feedback_service.dart';
import '../../services/permission_service.dart';

// ✅ NEW: Loadout imports
import '../../../loadout/domain/usecases/get_rifles.dart';
import '../../../loadout/domain/usecases/get_ammunition.dart';
import '../../../loadout/domain/usecases/get_scopes.dart';
import '../../domain/usecases/session-setup/set_active_Loadout.dart' as loadout_usecases;
import '../../../loadout/domain/entities/rifle.dart';
import '../../../loadout/domain/entities/ammunition.dart';
import '../../../loadout/domain/entities/scope.dart';

// ✅ NEW: Settings entities
import '../../domain/entities/session-setup/loadout_selection.dart';
import '../../domain/entities/session-setup/training_preferences.dart';
import '../../domain/entities/session-setup/available_device.dart';

import 'training_event.dart';
import 'training_state.dart';

class TrainingBloc extends Bloc<TrainingEvent, TrainingState> {
  final GetDeviceConnection getDeviceConnection;
  final ConnectDevice connectDevice;
  final StartSession startSession;
  final EndSession endSession;
  final StartMonitoring startMonitoring;
  final StopMonitoring stopMonitoring;
  final GetRealtimeReadings getRealtimeReadings;
  final CalibrateSensors calibrateSensors;
  final TrainingRepository trainingRepository;
  final AudioFeedbackService audioFeedbackService;

  // ✅ NEW: Loadout use cases
  final GetRifles getRifles;
  final GetAmmunition getAmmunition;
  final GetScopes getScopes;
  final loadout_usecases.SetActiveRifle setActiveRifle;

  StreamSubscription<AngleReading>? _readingSubscription;
  Timer? _sessionTimer;
  List<AngleReading> _sessionReadings = [];

  // ✅ NEW: Settings state
  LoadoutSelection _loadoutSelection = const LoadoutSelection();
  TrainingPreferences _preferences = TrainingPreferences.defaults();
  List<AvailableDevice> _availableDevices = [];
  bool _isScanning = false;
  bool _isSaving = false;

  // Add these to your TrainingBloc constructor in the event handler registrations:

  TrainingBloc({
    required this.getDeviceConnection,
    required this.connectDevice,
    required this.startSession,
    required this.endSession,
    required this.startMonitoring,
    required this.stopMonitoring,
    required this.getRealtimeReadings,
    required this.calibrateSensors,
    required this.trainingRepository,
    required this.audioFeedbackService,
    required this.getRifles,
    required this.getAmmunition,
    required this.getScopes,
    required this.setActiveRifle,
  }) : super(TrainingInitial()) {
    // Existing event handlers
    on<LoadTrainingData>(_onLoadTrainingData);
    on<LoadLoadoutStatus>(_onLoadLoadoutStatus);
    on<ConnectToDevice>(_onConnectToDevice);
    on<DisconnectDevice>(_onDisconnectDevice);
    on<ScanForDevices>(_onScanForDevices);
    on<StartMonitoringEvent>(_onStartMonitoring);
    on<StopMonitoringEvent>(_onStopMonitoring);
    on<StartSessionEvent>(_onStartSession);
    on<EndSessionEvent>(_onEndSession);
    on<CalibrateSensorsEvent>(_onCalibrateSensors);
    on<ChangePositionPreset>(_onChangePositionPreset);
    on<ToggleSoundAlerts>(_onToggleSoundAlerts);
    on<UpdateSoundVolume>(_onUpdateSoundVolume);
    on<ShowLevelDisplay>(_onShowLevelDisplay);
    on<HideLevelDisplay>(_onHideLevelDisplay);
    on<AngleReadingReceived>(_onAngleReadingReceived);

    // Settings events
    on<SetActiveRifleEvent>(_onSetActiveRifle);
    on<UpdateSoundEnabledEvent>(_onUpdateSoundEnabled);
    on<UpdateSoundVolumeEvent>(_onUpdateSoundVolumeSettings);
    on<UpdateAlertToneEvent>(_onUpdateAlertTone);
    on<TestSoundEvent>(_onTestSound);
    on<SaveAllSettingsEvent>(_onSaveAllSettings);

    // Enhanced setup events
    on<SetupBluetooth>(_onSetupBluetooth);
    on<EnableBluetooth>(_onEnableBluetooth);
    on<EnableLocation>(_onEnableLocation);
    on<RequestPermissions>(_onRequestPermissions);
    on<RetrySetup>(_onRetrySetup);

    // Custom tolerance events
    on<UpdateCustomCantTolerance>(_onUpdateCustomCantTolerance);
    on<UpdateCustomTiltTolerance>(_onUpdateCustomTiltTolerance);
    on<ResetCustomTolerances>(_onResetCustomTolerances);

    // ✅ NEW: Session Information Event Handlers
    on<ClearActiveRifleEvent>(_onClearActiveRifle);
    on<UpdateSessionNameEvent>(_onUpdateSessionName);
    on<UpdateSessionTypeEvent>(_onUpdateSessionType);
    on<UpdateSessionDateEvent>(_onUpdateSessionDate);
    on<UpdateSessionTimeEvent>(_onUpdateSessionTime);
    on<UpdateShootingPositionEvent>(_onUpdateShootingPosition);
    on<UpdateDistanceEvent>(_onUpdateDistance);
    on<ClearSessionInformationEvent>(_onClearSessionInformation);
  }


  @override
  Future<void> close() {
    _readingSubscription?.cancel();
    _sessionTimer?.cancel();
    audioFeedbackService.dispose();
    return super.close();
  }

  // ✅ NEW: Load loadout status
  Future<void> _onLoadLoadoutStatus(LoadLoadoutStatus event, Emitter<TrainingState> emit) async {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    emit(currentState.copyWith(isLoadingLoadoutStatus: true));

    try {
      // Get rifles and check active rifle
      final riflesResult = await getRifles(NoParams());

      riflesResult.fold(
            (failure) {
          print("TrainingBloc: Failed to load rifles: $failure");
          emit(currentState.copyWith(
            isLoadingLoadoutStatus: false,
            hasActiveLoadout: false,
          ));
        },
            (rifles) async {
          // Find active rifle
          final activeRifle = rifles.where((rifle) => rifle.isActive).firstOrNull;
          final hasActiveLoadout = activeRifle != null;

          _loadoutSelection = _loadoutSelection.copyWith(
            activeRifleId: activeRifle?.id,
            clearRifle: activeRifle == null,
          );

          print("TrainingBloc: Loadout status loaded - hasActiveLoadout: $hasActiveLoadout");
          emit(currentState.copyWith(
            isLoadingLoadoutStatus: false,
            hasActiveLoadout: hasActiveLoadout,
            availableRifles: rifles,
            loadoutSelection: _loadoutSelection,
          ));
        },
      );
    } catch (e) {
      print("TrainingBloc: Error loading loadout status: $e");
      emit(currentState.copyWith(
        isLoadingLoadoutStatus: false,
        hasActiveLoadout: false,
      ));
    }
  }

// ✅ UPDATED: _onLoadTrainingData method to include SessionInformation
  Future<void> _onLoadTrainingData(LoadTrainingData event, Emitter<TrainingState> emit) async {
    print("TrainingBloc: _onLoadTrainingData called");
    emit(TrainingLoading());

    try {
      final deviceResult = await getDeviceConnection(NoParams());

      await deviceResult.fold(
            (failure) async {
          print("TrainingBloc: Failed to get device connection");
          if (!emit.isDone) {
            emit(TrainingError(message: 'Failed to load training data'));
          }
        },
            (device) async {
          print("TrainingBloc: Successfully loaded training data");

          // ✅ FIXED: Properly await all async operations
          final riflesResult = await getRifles(NoParams());
          final ammunitionResult = await getAmmunition(NoParams());
          final scopesResult = await getScopes(NoParams());

          final rifles = riflesResult.fold((l) => <Rifle>[], (r) => r);
          final ammunition = ammunitionResult.fold((l) => <Ammunition>[], (r) => r);
          final scopes = scopesResult.fold((l) => <Scope>[], (r) => r);

          // Find active rifle
          final activeRifle = rifles.where((rifle) => rifle.isActive).firstOrNull;
          _loadoutSelection = _loadoutSelection.copyWith(
            activeRifleId: activeRifle?.id,
            clearRifle: activeRifle == null,
          );

          // Create initial state
          final initialState = TrainingLoaded(
            deviceConnection: device,
            isMonitoring: false,
            selectedPosition: PositionPreset.presets.last,
            soundEnabled: true,
            soundVolume: 75.0,
            levelDisplayVisible: false,
            availableDevices: [],
            isScanning: false,
            isCalibrating: false,
            isConnecting: false,
            isStartingMonitoring: false,
            bluetoothSetupResult: null,
            customCantTolerance: 2.0,
            customTiltTolerance: 2.0,
            hasActiveLoadout: activeRifle != null,
            isLoadingLoadoutStatus: false,
            // Settings state
            availableRifles: rifles,
            availableAmmunition: ammunition,
            availableScopes: scopes,
            loadoutSelection: _loadoutSelection,
            preferences: _preferences,
            settingsAvailableDevices: _availableDevices,
            isSettingsScanning: _isScanning,
            isSaving: _isSaving,
            // ✅ NEW: Initialize with default session information
            sessionInformation: const SessionInformation(),
          );

          // ✅ FIXED: Check if emit is still valid before calling
          if (!emit.isDone) {
            emit(initialState);
            audioFeedbackService.setEnabled(true);
          }
        },
      );
    } catch (e) {
      print("TrainingBloc: Error in _onLoadTrainingData: $e");
      // ✅ FIXED: Check if emit is still valid before calling
      if (!emit.isDone) {
        emit(TrainingError(message: 'Failed to load training data: $e'));
      }
    }
  }

  // Fix for _onConnectToDevice method
  Future<void> _onConnectToDevice(ConnectToDevice event, Emitter<TrainingState> emit) async {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    print("TrainingBloc: _onConnectToDevice called with deviceId: ${event.deviceId}");

    emit(currentState.copyWith(
        isScanning: false,
        isConnecting: true,
        isSettingsScanning: false
    ));

    try {
      final result = await connectDevice(ConnectDeviceParams(deviceId: event.deviceId));

      await result.fold(
            (failure) async {
          print("TrainingBloc: Connection failed: $failure");
          if (!emit.isDone) {
            emit(currentState.copyWith(isConnecting: false));
            emit(TrainingError(message: 'Failed to connect to device: ${failure.toString()}'));
          }
        },
            (_) async {
          print("TrainingBloc: Connection successful, getting device info");

          final deviceResult = await getDeviceConnection(NoParams());

          await deviceResult.fold(
                (failure) async {
              print("TrainingBloc: Failed to get device connection after connect");
              if (!emit.isDone) {
                emit(currentState.copyWith(isConnecting: false));
                emit(TrainingError(message: 'Failed to get device connection'));
              }
            },
                (connectedDevice) async {
              print("TrainingBloc: Device connection successful: ${connectedDevice?.deviceName}");
              if (!emit.isDone) {
                emit(currentState.copyWith(
                  deviceConnection: connectedDevice,
                  availableDevices: [],
                  settingsAvailableDevices: [],
                  isScanning: false,
                  isConnecting: false,
                  isSettingsScanning: false,
                ));

                // ✅ NEW: Refresh loadout status after device connection
                add(LoadLoadoutStatus());
              }
            },
          );
        },
      );
    } catch (e) {
      print("TrainingBloc: Exception in _onConnectToDevice: $e");
      if (!emit.isDone) {
        emit(currentState.copyWith(isConnecting: false));
        emit(TrainingError(message: 'Connection error: $e'));
      }
    }
  }

// Fix for _onSetActiveRifle method
  Future<void> _onSetActiveRifle(SetActiveRifleEvent event, Emitter<TrainingState> emit) async {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;

    try {
      final result = await setActiveRifle(loadout_usecases.SetActiveRifleParams(rifleId: event.rifleId));

      await result.fold(
            (failure) async {
          if (!emit.isDone) {
            emit(TrainingError(message: 'Failed to set active rifle'));
          }
        },
            (_) async {
          _loadoutSelection = _loadoutSelection.copyWith(activeRifleId: event.rifleId);

          if (!emit.isDone) {
            emit(currentState.copyWith(
              loadoutSelection: _loadoutSelection,
              hasActiveLoadout: true,
            ));
          }

          print("TrainingBloc: Active rifle set to: ${event.rifleId}");
        },
      );
    } catch (e) {
      if (!emit.isDone) {
        emit(TrainingError(message: 'Error setting active rifle: $e'));
      }
    }
  }

// Fix for _onScanForDevices method
  Future<void> _onScanForDevices(ScanForDevices event, Emitter<TrainingState> emit) async {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    print("TrainingBloc: _onScanForDevices called");

    emit(currentState.copyWith(
      isScanning: true,
      isSettingsScanning: true,
    ));

    try {
      final result = await trainingRepository.scanForDevices();

      await result.fold(
            (failure) async {
          print("TrainingBloc: Scan failed: $failure");
          if (!emit.isDone) {
            emit(TrainingError(message: 'Failed to scan for devices: ${failure.toString()}'));
          }
        },
            (devices) async {
          print("TrainingBloc: Scan successful, found devices: $devices");
          if (!emit.isDone) {
            final currentState = state as TrainingLoaded;
            _availableDevices = devices.map((name) => AvailableDevice(
              deviceId: name,
              deviceName: name,
              signalStrength: 'Strong',
            )).toList();

            emit(currentState.copyWith(
              isScanning: false,
              availableDevices: devices,
              isSettingsScanning: false,
              settingsAvailableDevices: _availableDevices,
            ));
          }
        },
      );
    } catch (e) {
      print("TrainingBloc: Exception in scan: $e");
      if (!emit.isDone) {
        emit(TrainingError(message: 'Scan error: $e'));
      }
    }
  }

  // Fix for _onStartMonitoring method
  Future<void> _onStartMonitoring(StartMonitoringEvent event, Emitter<TrainingState> emit) async {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    print("TrainingBloc: _onStartMonitoring called");

    // ✅ NEW: Check both device connection and loadout status
    if (!currentState.isDeviceConnected) {
      emit(TrainingError(message: 'Device not connected'));
      return;
    }

    if (!currentState.hasActiveLoadout) {
      emit(TrainingError(message: 'No active loadout configured. Please activate a loadout first.'));
      return;
    }

    emit(currentState.copyWith(isStartingMonitoring: true));

    try {
      final result = await startMonitoring(NoParams());

      await result.fold(
            (failure) async {
          print("TrainingBloc: Start monitoring failed: $failure");
          if (!emit.isDone) {
            emit(currentState.copyWith(isStartingMonitoring: false));
            emit(TrainingError(message: 'Failed to start monitoring: ${failure.toString()}'));
          }
        },
            (_) async {
          print("TrainingBloc: Monitoring started successfully");
          if (!emit.isDone) {
            emit(currentState.copyWith(
              isMonitoring: true,
              isStartingMonitoring: false,
            ));

            audioFeedbackService.setActive(true);
            audioFeedbackService.setEnabled(currentState.soundEnabled);

            _startRealtimeReadings();
            _startDeviceConnectionCheck();
          }
        },
      );
    } catch (e) {
      print("TrainingBloc: Exception in start monitoring: $e");
      if (!emit.isDone) {
        emit(currentState.copyWith(isStartingMonitoring: false));
        emit(TrainingError(message: 'Start monitoring error: $e'));
      }
    }
  }

// Fix for _onStopMonitoring method
  Future<void> _onStopMonitoring(StopMonitoringEvent event, Emitter<TrainingState> emit) async {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    print("TrainingBloc: _onStopMonitoring called (MANUAL STOP)");

    try {
      _manualStopInProgress = true;

      _deviceCheckTimer?.cancel();
      _deviceCheckTimer = null;

      _stopRealtimeReadings();

      audioFeedbackService.setActive(false);

      final result = await stopMonitoring(NoParams());

      await result.fold(
            (failure) async {
          print("TrainingBloc: Stop monitoring failed: $failure");
          _manualStopInProgress = false;
          if (!emit.isDone) {
            emit(TrainingError(message: 'Failed to stop monitoring: ${failure.toString()}'));
          }
        },
            (_) async {
          print("TrainingBloc: Monitoring stopped successfully (DEVICE REMAINS CONNECTED)");
          _manualStopInProgress = false;
          if (!emit.isDone) {
            emit(currentState.copyWith(isMonitoring: false));
          }
        },
      );
    } catch (e) {
      print("TrainingBloc: Exception in stop monitoring: $e");
      _manualStopInProgress = false;
      if (!emit.isDone) {
        emit(TrainingError(message: 'Stop monitoring error: $e'));
      }
    }
  }

// Fix for _onCalibrateSensors method
  Future<void> _onCalibrateSensors(CalibrateSensorsEvent event, Emitter<TrainingState> emit) async {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    print("TrainingBloc: _onCalibrateSensors called");

    emit(currentState.copyWith(isCalibrating: true));

    try {
      final result = await calibrateSensors(NoParams());

      await result.fold(
            (failure) async {
          print("TrainingBloc: Calibration failed: $failure");
          if (!emit.isDone) {
            emit(TrainingError(message: 'Failed to calibrate sensors: ${failure.toString()}'));
          }
        },
            (_) async {
          print("TrainingBloc: Calibration successful");
          await Future.delayed(const Duration(seconds: 1));

          final readingResult = await trainingRepository.getCurrentReading();
          await readingResult.fold(
                (failure) async {
              print("TrainingBloc: Failed to get reading after calibration");
              if (!emit.isDone) {
                emit(currentState.copyWith(isCalibrating: false));
              }
            },
                (reading) async {
              print("TrainingBloc: Got reading after calibration: ${reading.cant}°, ${reading.tilt}°");
              if (!emit.isDone) {
                emit(currentState.copyWith(
                  isCalibrating: false,
                  currentReading: reading,
                ));
              }
            },
          );
        },
      );
    } catch (e) {
      print("TrainingBloc: Exception in calibration: $e");
      if (!emit.isDone) {
        emit(TrainingError(message: 'Calibration error: $e'));
      }
    }
  }



  // ✅ NEW: Settings sound events
  void _onUpdateSoundEnabled(UpdateSoundEnabledEvent event, Emitter<TrainingState> emit) {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    _preferences = _preferences.copyWith(soundEnabled: event.enabled);

    emit(currentState.copyWith(
      preferences: _preferences,
      soundEnabled: event.enabled,
    ));

    audioFeedbackService.setEnabled(event.enabled);
    print("TrainingBloc: Sound ${event.enabled ? 'enabled' : 'disabled'}");
  }

  void _onUpdateSoundVolumeSettings(UpdateSoundVolumeEvent event, Emitter<TrainingState> emit) {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    _preferences = _preferences.copyWith(soundVolume: event.volume);

    emit(currentState.copyWith(
      preferences: _preferences,
      soundVolume: event.volume,
    ));

    print("TrainingBloc: Sound volume updated to ${event.volume}%");
  }

  void _onUpdateAlertTone(UpdateAlertToneEvent event, Emitter<TrainingState> emit) {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    _preferences = _preferences.copyWith(alertTone: event.alertTone);

    emit(currentState.copyWith(preferences: _preferences));
  }

  Future<void> _onTestSound(TestSoundEvent event, Emitter<TrainingState> emit) async {
    // Test sound functionality can be implemented here
    print('Testing sound: ${event.alertTone}');
  }

  Future<void> _onSaveAllSettings(SaveAllSettingsEvent event, Emitter<TrainingState> emit) async {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    emit(currentState.copyWith(isSaving: true));

    // Simulate saving
    await Future.delayed(const Duration(milliseconds: 500));

    emit(currentState.copyWith(isSaving: false));
    print("TrainingBloc: All settings saved successfully");
  }




  Future<void> _onDisconnectDevice(DisconnectDevice event, Emitter<TrainingState> emit) async {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    print("TrainingBloc: _onDisconnectDevice called");

    try {
      audioFeedbackService.setActive(false);

      if (currentState.isMonitoring) {
        print("TrainingBloc: Stopping monitoring before disconnect");
        add(StopMonitoringEvent());
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (currentState.isSessionActive) {
        print("TrainingBloc: Ending session before disconnect");
        add(EndSessionEvent());
        await Future.delayed(const Duration(milliseconds: 500));
      }

      await trainingRepository.disconnectDevice();
      print("TrainingBloc: Device disconnected successfully");

      if (!emit.isDone) {
        emit(currentState.copyWith(clearDeviceConnection: true));
      }
    } catch (e) {
      print("TrainingBloc: Error in disconnect: $e");
      if (!emit.isDone) {
        emit(TrainingError(message: 'Disconnect error: $e'));
      }
    }
  }

  // Custom tolerance event handlers
  void _onUpdateCustomCantTolerance(UpdateCustomCantTolerance event, Emitter<TrainingState> emit) {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    emit(currentState.copyWith(customCantTolerance: event.cantTolerance));
    print("TrainingBloc: Custom cant tolerance updated to: ±${event.cantTolerance}°");
  }

  void _onUpdateCustomTiltTolerance(UpdateCustomTiltTolerance event, Emitter<TrainingState> emit) {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    emit(currentState.copyWith(customTiltTolerance: event.tiltTolerance));
    print("TrainingBloc: Custom tilt tolerance updated to: ±${event.tiltTolerance}°");
  }

  void _onResetCustomTolerances(ResetCustomTolerances event, Emitter<TrainingState> emit) {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    emit(currentState.copyWith(
      customCantTolerance: 2.0,
      customTiltTolerance: 2.0,
    ));
    print("TrainingBloc: Custom tolerances reset to default values");
  }

  // New comprehensive Bluetooth setup methods
  Future<void> _onSetupBluetooth(SetupBluetooth event, Emitter<TrainingState> emit) async {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    print("TrainingBloc: _onSetupBluetooth called");

    try {
      final result = await PermissionService.setupBluetooth();
      print("TrainingBloc: Setup result: ${result.status}");

      emit(currentState.copyWith(
        bluetoothSetupResult: result,
      ));

      if (result.isReady) {
        add(ScanForDevices());
      }
    } catch (e) {
      print("TrainingBloc: Error in setup: $e");
      emit(TrainingError(message: 'Setup error: $e'));
    }
  }

  Future<void> _onEnableBluetooth(EnableBluetooth event, Emitter<TrainingState> emit) async {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    print("TrainingBloc: _onEnableBluetooth called");

    try {
      final success = await PermissionService.enableBluetooth();

      if (success) {
        print("TrainingBloc: Bluetooth enabled successfully");
        add(SetupBluetooth());
      } else {
        print("TrainingBloc: Failed to enable Bluetooth");
        emit(TrainingError(message: 'Failed to enable Bluetooth. Please enable it manually in Settings.'));
      }
    } catch (e) {
      print("TrainingBloc: Error enabling Bluetooth: $e");
      emit(TrainingError(message: 'Error enabling Bluetooth: $e'));
    }
  }

  Future<void> _onEnableLocation(EnableLocation event, Emitter<TrainingState> emit) async {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    print("TrainingBloc: _onEnableLocation called");

    try {
      final success = await PermissionService.enableLocation();

      if (success) {
        print("TrainingBloc: Location enabled successfully");
        add(SetupBluetooth());
      } else {
        print("TrainingBloc: Failed to enable Location");
        emit(TrainingError(message: 'Failed to enable Location services. Please enable them manually in Settings.'));
      }
    } catch (e) {
      print("TrainingBloc: Error enabling Location: $e");
      emit(TrainingError(message: 'Error enabling Location: $e'));
    }
  }

  Future<void> _onRequestPermissions(RequestPermissions event, Emitter<TrainingState> emit) async {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    print("TrainingBloc: _onRequestPermissions called");

    try {
      final result = await PermissionService.requestPermissions();

      switch (result) {
        case PermissionRequestResult.granted:
          print("TrainingBloc: Permissions granted successfully");
          add(SetupBluetooth());
          break;

        case PermissionRequestResult.denied:
          print("TrainingBloc: Some permissions denied");
          emit(currentState.copyWith(
            bluetoothSetupResult: BluetoothSetupResult.permissionsNeeded(
                PermissionCheckResult.denied
            ),
          ));
          break;

        case PermissionRequestResult.permanentlyDenied:
          print("TrainingBloc: Some permissions permanently denied");
          emit(currentState.copyWith(
            bluetoothSetupResult: BluetoothSetupResult.permissionsNeeded(
                PermissionCheckResult.permanentlyDenied
            ),
          ));
          break;

        case PermissionRequestResult.error:
          print("TrainingBloc: Error requesting permissions");
          emit(TrainingError(message: 'Error requesting permissions'));
          break;
      }
    } catch (e) {
      print("TrainingBloc: Exception requesting permissions: $e");
      emit(TrainingError(message: 'Error requesting permissions: $e'));
    }
  }

  Future<void> _onRetrySetup(RetrySetup event, Emitter<TrainingState> emit) async {
    if (state is! TrainingLoaded) return;

    print("TrainingBloc: _onRetrySetup called");
    add(SetupBluetooth());
  }



  // Device connection check and other methods remain the same...
  Timer? _deviceCheckTimer;
  bool _manualStopInProgress = false;

  void _handleDeviceDisconnected() {
    if (!isClosed && state is TrainingLoaded) {
      print("TrainingBloc: Handling device disconnection - stopping audio and updating UI");

      audioFeedbackService.setActive(false);

      final currentState = state as TrainingLoaded;
      emit(currentState.copyWith(
        clearDeviceConnection: true,
        isMonitoring: false,
      ));

      _readingSubscription?.cancel();
      _readingSubscription = null;
      _deviceCheckTimer?.cancel();
      _deviceCheckTimer = null;
    }
  }


  void _onAngleReadingReceived(AngleReadingReceived event, Emitter<TrainingState> emit) {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    final reading = AngleReading(
      cant: event.cant,
      tilt: event.tilt,
      pan: event.pan,
      timestamp: DateTime.now(),
    );

    audioFeedbackService.processAngleReading(reading, currentState.currentPositionWithCustomValues);

    if (currentState.isSessionActive) {
      _sessionReadings.add(reading);

      final stats = _calculateSessionStats();
      emit(currentState.copyWith(
        currentReading: reading,
        sessionStats: stats,
      ));
    } else {
      emit(currentState.copyWith(currentReading: reading));
    }
  }

  SessionStats _calculateSessionStats() {
    if (_sessionReadings.isEmpty) {
      return const SessionStats(
        averageCant: 0.0,
        averageTilt: 0.0,
        stabilityPercentage: 0.0,
        goodHolds: 0,
        totalReadings: 0,
      );
    }

    final state = this.state as TrainingLoaded;
    final preset = state.currentPositionWithCustomValues;

    final avgCant = _sessionReadings
        .map((r) => r.cant.abs())
        .reduce((a, b) => a + b) / _sessionReadings.length;

    final avgTilt = _sessionReadings
        .map((r) => r.tilt.abs())
        .reduce((a, b) => a + b) / _sessionReadings.length;

    final goodHolds = _sessionReadings.where((reading) {
      return reading.cant.abs() <= preset.cantTolerance &&
          reading.tilt.abs() <= preset.tiltTolerance;
    }).length;

    final stabilityPercentage = (goodHolds / _sessionReadings.length) * 100;

    return SessionStats(
      averageCant: double.parse(avgCant.toStringAsFixed(1)),
      averageTilt: double.parse(avgTilt.toStringAsFixed(1)),
      stabilityPercentage: double.parse(stabilityPercentage.toStringAsFixed(1)),
      goodHolds: goodHolds,
      totalReadings: _sessionReadings.length,
    );
  }

  void _startRealtimeReadings() {
    print("TrainingBloc: Starting real-time sensor readings from hardware");

    _readingSubscription?.cancel();

    Timer? _dataTimeoutTimer;
    DateTime _lastDataReceived = DateTime.now();
    const Duration _dataTimeout = Duration(milliseconds: 500);

    try {
      _readingSubscription = trainingRepository.getRealtimeReadings().listen(
            (angleReading) {
          if (!isClosed) {
            add(AngleReadingReceived(
              cant: angleReading.cant,
              tilt: angleReading.tilt,
              pan: angleReading.pan,
            ));
          }
        },
        onError: (error) {
          print("TrainingBloc: Error in sensor data stream: $error");

          if (!isClosed && !_manualStopInProgress) {
            print("TrainingBloc: Automatic disconnect detected (stream error)");
            _handleAutomaticDisconnect();
          } else {
            print("TrainingBloc: Stream error during manual stop - ignoring");
          }
        },
        onDone: () {
          print("TrainingBloc: Sensor data stream completed");

          if (!isClosed && !_manualStopInProgress) {
            print("TrainingBloc: Automatic disconnect detected (stream done)");
            _handleAutomaticDisconnect();
          } else {
            print("TrainingBloc: Stream completed during manual stop - ignoring");
          }
        },
      );
    } catch (e) {
      print("TrainingBloc: Exception starting realtime readings: $e");
      if (!isClosed && !_manualStopInProgress) {
        _handleAutomaticDisconnect();
      }
    }
  }

  void _stopRealtimeReadings() {
    print("TrainingBloc: Stopping real-time sensor readings (MANUAL)");

    _readingSubscription?.cancel();
    _readingSubscription = null;

    _deviceCheckTimer?.cancel();
    _deviceCheckTimer = null;
  }

  void _startDeviceConnectionCheck() {
    _deviceCheckTimer?.cancel();

    _deviceCheckTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) async {
      if (!isClosed && state is TrainingLoaded) {
        final currentState = state as TrainingLoaded;

        if (!currentState.isMonitoring || _manualStopInProgress) {
          timer.cancel();
          return;
        }

        try {
          final deviceResult = await getDeviceConnection(NoParams());

          deviceResult.fold(
                (failure) {
              if (!_manualStopInProgress) {
                print("TrainingBloc: Device check failed - likely disconnected");
                timer.cancel();
                _handleAutomaticDisconnect();
              }
            },
                (device) {
              if (!_manualStopInProgress && (device == null || !device.isConnected)) {
                print("TrainingBloc: Device disconnected detected in periodic check");
                timer.cancel();
                _handleAutomaticDisconnect();
              }
            },
          );
        } catch (e) {
          if (!_manualStopInProgress) {
            print("TrainingBloc: Error in device check: $e");
            timer.cancel();
            _handleAutomaticDisconnect();
          }
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _handleAutomaticDisconnect() {
    if (!isClosed && state is TrainingLoaded && !_manualStopInProgress) {
      print("TrainingBloc: Handling AUTOMATIC device disconnection");

      audioFeedbackService.setActive(false);

      final currentState = state as TrainingLoaded;
      emit(currentState.copyWith(
        clearDeviceConnection: true,
        isMonitoring: false,
      ));

      _readingSubscription?.cancel();
      _readingSubscription = null;
      _deviceCheckTimer?.cancel();
      _deviceCheckTimer = null;
    } else {
      print("TrainingBloc: Ignoring disconnect during manual stop");
    }
  }

  Future<void> _onStartSession(StartSessionEvent event, Emitter<TrainingState> emit) async {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    print("TrainingBloc: _onStartSession called: ${event.sessionName}");

    try {
      final session = TrainingSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: event.sessionName,
        type: event.sessionType,
        notes: event.notes,
        weather: event.weather,
        windSpeed: event.windSpeed,
        temperature: event.temperature,
        humidity: event.humidity,
        startTime: DateTime.now(),
        readings: [],
        stats: const SessionStats(
          averageCant: 0.0,
          averageTilt: 0.0,
          stabilityPercentage: 0.0,
          goodHolds: 0,
          totalReadings: 0,
        ),
      );

      final result = await startSession(StartSessionParams(session: session));

      result.fold(
            (failure) {
          print("TrainingBloc: Start session failed: $failure");
          emit(TrainingError(message: 'Failed to start session: ${failure.toString()}'));
        },
            (startedSession) {
          print("TrainingBloc: Session started successfully: ${startedSession.name}");
          emit(currentState.copyWith(activeSession: startedSession));
          _sessionReadings = [];

          if (!currentState.isMonitoring) {
            add(StartMonitoringEvent());
          }

          _startSessionTimer();
        },
      );
    } catch (e) {
      print("TrainingBloc: Exception in start session: $e");
      emit(TrainingError(message: 'Start session error: $e'));
    }
  }

  Future<void> _onEndSession(EndSessionEvent event, Emitter<TrainingState> emit) async {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    print("TrainingBloc: _onEndSession called");

    if (currentState.activeSession == null) {
      print("TrainingBloc: No active session to end");
      return;
    }

    try {
      final result = await endSession(EndSessionParams(sessionId: currentState.activeSession!.id));

      result.fold(
            (failure) {
          print("TrainingBloc: End session failed: $failure");
          emit(TrainingError(message: 'Failed to end session: ${failure.toString()}'));
        },
            (endedSession) {
          print("TrainingBloc: Session ended successfully: ${endedSession.name}");
          emit(currentState.copyWith(clearActiveSession: true));
          _stopSessionTimer();
        },
      );
    } catch (e) {
      print("TrainingBloc: Exception in end session: $e");
      emit(TrainingError(message: 'End session error: $e'));
    }
  }


  void _onChangePositionPreset(ChangePositionPreset event, Emitter<TrainingState> emit) {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    emit(currentState.copyWith(selectedPosition: event.preset));

    print("TrainingBloc: Position preset changed to: ${event.preset.name}");
    print("TrainingBloc: New tolerances - Cant: ±${event.preset.cantTolerance}°, Tilt: ±${event.preset.tiltTolerance}°");
  }

  void _onToggleSoundAlerts(ToggleSoundAlerts event, Emitter<TrainingState> emit) {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    final newSoundEnabled = !currentState.soundEnabled;

    _preferences = _preferences.copyWith(soundEnabled: newSoundEnabled);

    emit(currentState.copyWith(
      soundEnabled: newSoundEnabled,
      preferences: _preferences,
    ));

    audioFeedbackService.setEnabled(newSoundEnabled);

    print("TrainingBloc: Sound alerts ${newSoundEnabled ? 'enabled' : 'disabled'}");
  }

  void _onUpdateSoundVolume(UpdateSoundVolume event, Emitter<TrainingState> emit) {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    _preferences = _preferences.copyWith(soundVolume: event.volume);

    emit(currentState.copyWith(
      soundVolume: event.volume,
      preferences: _preferences,
    ));

    print("TrainingBloc: Sound volume updated to: ${event.volume}%");
  }

  void _onShowLevelDisplay(ShowLevelDisplay event, Emitter<TrainingState> emit) {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    emit(currentState.copyWith(levelDisplayVisible: true));
  }

  void _onHideLevelDisplay(HideLevelDisplay event, Emitter<TrainingState> emit) {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    emit(currentState.copyWith(levelDisplayVisible: false));
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Timer triggers UI updates automatically
    });
  }

  void _stopSessionTimer() {
    _sessionTimer?.cancel();
  }



  // Additional event handlers for TrainingBloc class
// Add these methods to your existing TrainingBloc class

// ✅ NEW: Clear Active Rifle Event Handler
  Future<void> _onClearActiveRifle(ClearActiveRifleEvent event, Emitter<TrainingState> emit) async {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;

    try {
      // Clear active rifle in repository by setting null/empty
      // Note: Adjust this based on your repository implementation
      final result = await trainingRepository.setActiveRifle(''); // Empty string to clear

      await result.fold(
            (failure) async {
          if (!emit.isDone) {
            emit(TrainingError(message: 'Failed to clear active rifle'));
          }
        },
            (_) async {
          // ✅ FIXED: Properly clear the loadout selection
          _loadoutSelection = const LoadoutSelection(); // Reset to default

          if (!emit.isDone) {
            emit(currentState.copyWith(
              loadoutSelection: _loadoutSelection,
              hasActiveLoadout: false,
            ));
          }

          print("TrainingBloc: Active rifle cleared");
        },
      );
    } catch (e) {
      if (!emit.isDone) {
        emit(TrainingError(message: 'Error clearing active rifle: $e'));
      }
    }
  }
// ✅ NEW: Session Information Event Handlers
  void _onUpdateSessionName(UpdateSessionNameEvent event, Emitter<TrainingState> emit) {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    final updatedSessionInfo = currentState.sessionInformation.copyWith(
      sessionName: event.sessionName.trim().isEmpty ? null : event.sessionName.trim(),
    );

    emit(currentState.copyWith(sessionInformation: updatedSessionInfo));
    print("TrainingBloc: Session name updated to: ${event.sessionName}");
  }

  void _onUpdateSessionType(UpdateSessionTypeEvent event, Emitter<TrainingState> emit) {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    final updatedSessionInfo = currentState.sessionInformation.copyWith(
      sessionType: event.sessionType.trim().isEmpty ? null : event.sessionType.trim(),
    );

    emit(currentState.copyWith(sessionInformation: updatedSessionInfo));
    print("TrainingBloc: Session type updated to: ${event.sessionType}");
  }

  void _onUpdateSessionDate(UpdateSessionDateEvent event, Emitter<TrainingState> emit) {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    final updatedSessionInfo = currentState.sessionInformation.copyWith(
      date: event.date,
    );

    emit(currentState.copyWith(sessionInformation: updatedSessionInfo));
    print("TrainingBloc: Session date updated to: ${event.date}");
  }

  void _onUpdateSessionTime(UpdateSessionTimeEvent event, Emitter<TrainingState> emit) {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    final updatedSessionInfo = currentState.sessionInformation.copyWith(
      time: event.time,
    );

    emit(currentState.copyWith(sessionInformation: updatedSessionInfo));
    print("TrainingBloc: Session time updated to: ${event.time}");
  }

  void _onUpdateShootingPosition(UpdateShootingPositionEvent event, Emitter<TrainingState> emit) {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    final updatedSessionInfo = currentState.sessionInformation.copyWith(
      shootingPosition: event.shootingPosition.trim().isEmpty ? null : event.shootingPosition.trim(),
    );

    emit(currentState.copyWith(sessionInformation: updatedSessionInfo));
    print("TrainingBloc: Shooting position updated to: ${event.shootingPosition}");
  }

  void _onUpdateDistance(UpdateDistanceEvent event, Emitter<TrainingState> emit) {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    final updatedSessionInfo = currentState.sessionInformation.copyWith(
      distance: event.distance.trim().isEmpty ? null : event.distance.trim(),
    );

    emit(currentState.copyWith(sessionInformation: updatedSessionInfo));
    print("TrainingBloc: Distance updated to: ${event.distance}");
  }

  void _onClearSessionInformation(ClearSessionInformationEvent event, Emitter<TrainingState> emit) {
    if (state is! TrainingLoaded) return;

    final currentState = state as TrainingLoaded;
    const clearedSessionInfo = SessionInformation();

    emit(currentState.copyWith(sessionInformation: clearedSessionInfo));
    print("TrainingBloc: Session information cleared");
  }


// ✅ UPDATED: Constructor with new event handlers
// Add these to your TrainingBloc constructor's event handlers:
/*
In your TrainingBloc constructor, add these event handlers:

on<ClearActiveRifleEvent>(_onClearActiveRifle);
on<UpdateSessionNameEvent>(_onUpdateSessionName);
on<UpdateSessionTypeEvent>(_onUpdateSessionType);
on<UpdateSessionDateEvent>(_onUpdateSessionDate);
on<UpdateSessionTimeEvent>(_onUpdateSessionTime);
on<UpdateShootingPositionEvent>(_onUpdateShootingPosition);
on<UpdateDistanceEvent>(_onUpdateDistance);
on<ClearSessionInformationEvent>(_onClearSessionInformation);
*/

// ✅ UPDATED: LoadTrainingData to include SessionInformation
/*
Update your _onLoadTrainingData method to include initial sessionInformation:

In the initialState creation, add:
sessionInformation: const SessionInformation(),
*/
}