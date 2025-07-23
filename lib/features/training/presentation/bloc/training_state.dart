// lib/features/training/presentation/bloc/training_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/device_connection.dart';
import '../../domain/entities/session-setup/session_information.dart';
import '../../domain/entities/training_session.dart';
import '../../domain/entities/angle_reading.dart';
import '../../domain/entities/position_preset.dart';
import '../../domain/entities/session_stats.dart';
import '../../services/permission_service.dart';

// ✅ NEW: Settings imports
import '../../domain/entities/session-setup/loadout_selection.dart';
import '../../domain/entities/session-setup/training_preferences.dart';
import '../../domain/entities/session-setup/available_device.dart';
import '../../../loadout/domain/entities/rifle.dart';
import '../../../loadout/domain/entities/ammunition.dart';
import '../../../loadout/domain/entities/scope.dart';

abstract class TrainingState extends Equatable {
  const TrainingState();

  @override
  List<Object?> get props => [];
}

class TrainingInitial extends TrainingState {}

class TrainingLoading extends TrainingState {}

class TrainingLoaded extends TrainingState {
  final DeviceConnection? deviceConnection;
  final TrainingSession? activeSession;
  final bool isMonitoring;
  final AngleReading? currentReading;
  final PositionPreset selectedPosition;
  final bool soundEnabled;
  final double soundVolume;
  final bool levelDisplayVisible;
  final List<String> availableDevices;
  final bool isScanning;
  final bool isCalibrating;
  final SessionStats? sessionStats;
  final bool isConnecting;
  final bool isStartingMonitoring;

  // Bluetooth setup result for comprehensive status tracking
  final BluetoothSetupResult? bluetoothSetupResult;

  // ✅ NEW: Loadout status tracking
  final bool hasActiveLoadout;
  final bool isLoadingLoadoutStatus;

  // Custom tolerance values
  final double customCantTolerance;
  final double customTiltTolerance;

  // ✅ NEW: Settings properties
  final List<Rifle> availableRifles;
  final List<Ammunition> availableAmmunition;
  final List<Scope> availableScopes;
  final LoadoutSelection loadoutSelection;
  final TrainingPreferences preferences;
  final List<AvailableDevice> settingsAvailableDevices;
  final bool isSettingsScanning;
  final bool isSaving;

  // ✅ NEW: Session Information tracking
  final SessionInformation sessionInformation;

  const TrainingLoaded({
    this.deviceConnection,
    this.activeSession,
    required this.isMonitoring,
    this.currentReading,
    required this.selectedPosition,
    required this.soundEnabled,
    required this.soundVolume,
    required this.levelDisplayVisible,
    required this.availableDevices,
    required this.isScanning,
    required this.isCalibrating,
    this.isConnecting = false,
    this.isStartingMonitoring = false,
    this.sessionStats,
    this.bluetoothSetupResult,
    this.hasActiveLoadout = false,
    this.isLoadingLoadoutStatus = false,
    this.customCantTolerance = 2.0,
    this.customTiltTolerance = 2.0,
    // ✅ NEW: Settings properties
    this.availableRifles = const [],
    this.availableAmmunition = const [],
    this.availableScopes = const [],
    this.loadoutSelection = const LoadoutSelection(),
    this.preferences = const TrainingPreferences(soundEnabled: true, soundVolume: 75.0, alertTone: 'beep'),
    this.settingsAvailableDevices = const [],
    this.isSettingsScanning = false,
    this.isSaving = false,
    // ✅ NEW: Session Information
    this.sessionInformation = const SessionInformation(),
  });

  bool get isDeviceConnected => deviceConnection?.isConnected ?? false;
  bool get isSessionActive => activeSession?.isActive ?? false;

  // ✅ NEW: Training ready when both device connected AND loadout active
  bool get isTrainingReady => isDeviceConnected && hasActiveLoadout;

  // ✅ NEW: Completion tracking getters
  bool get isDeviceConnectionComplete => isDeviceConnected;

  bool get isLoadoutConfigurationComplete {
    // Device connected + Active rifle with ammunition
    return hasActiveLoadout && activeRifle != null && activeRifle!.ammunition != null;
  }

  bool get isSessionInformationComplete => sessionInformation.isComplete;

  // ✅ NEW: Dynamic completed sections count
  int get completedSections {
    int count = 0;
    if (isDeviceConnectionComplete) count++;
    if (isLoadoutConfigurationComplete) count++;
    if (isSessionInformationComplete) count++;
    return count;
  }

  // ✅ NEW: Section completion status map for easy access
  Map<String, bool> get sectionCompletions => {
    'device': isDeviceConnectionComplete,
    'loadout': isLoadoutConfigurationComplete,
    'session': isSessionInformationComplete,
  };

  // Convenient getters for setup status
  bool get isBluetoothReady => bluetoothSetupResult?.isReady ?? false;
  bool get needsBluetoothEnable => bluetoothSetupResult?.needsBluetooth ?? false;
  bool get needsLocationEnable => bluetoothSetupResult?.needsLocation ?? false;
  bool get needsPermissions => bluetoothSetupResult?.needsPermissions ?? false;

  // ✅ NEW: Active rifle getter
  Rifle? get activeRifle {
    if (loadoutSelection.activeRifleId == null) return null;
    try {
      return availableRifles.firstWhere(
            (rifle) => rifle.id == loadoutSelection.activeRifleId,
      );
    } catch (e) {
      return null;
    }
  }

  // ✅ NEW: Available rifles with ammunition filter
  List<Rifle> get availableRiflesWithAmmo {
    return availableRifles.where((rifle) => rifle.ammunition != null).toList();
  }

  // ✅ NEW: Available rifles without ammunition (for display with warning)
  List<Rifle> get availableRiflesWithoutAmmo {
    return availableRifles.where((rifle) => rifle.ammunition == null).toList();
  }

  // Get current position with custom values if needed
  PositionPreset get currentPositionWithCustomValues {
    if (selectedPosition.id == 'custom') {
      return PositionPreset(
        id: 'custom',
        name: 'Custom',
        description: 'Custom tolerances',
        cantTolerance: customCantTolerance,
        tiltTolerance: customTiltTolerance,
        panTolerance: selectedPosition.panTolerance,
      );
    }
    return selectedPosition;
  }

  TrainingLoaded copyWith({
    DeviceConnection? deviceConnection,
    TrainingSession? activeSession,
    bool? isMonitoring,
    AngleReading? currentReading,
    PositionPreset? selectedPosition,
    bool? soundEnabled,
    double? soundVolume,
    bool? levelDisplayVisible,
    List<String>? availableDevices,
    bool? isScanning,
    bool? isCalibrating,
    SessionStats? sessionStats,
    bool clearActiveSession = false,
    bool clearDeviceConnection = false,
    bool? isConnecting,
    bool? isStartingMonitoring,
    BluetoothSetupResult? bluetoothSetupResult,
    bool? hasActiveLoadout,
    bool? isLoadingLoadoutStatus,
    double? customCantTolerance,
    double? customTiltTolerance,
    // ✅ NEW: Settings copyWith parameters
    List<Rifle>? availableRifles,
    List<Ammunition>? availableAmmunition,
    List<Scope>? availableScopes,
    LoadoutSelection? loadoutSelection,
    TrainingPreferences? preferences,
    List<AvailableDevice>? settingsAvailableDevices,
    bool? isSettingsScanning,
    bool? isSaving,
    // ✅ NEW: Session Information copyWith
    SessionInformation? sessionInformation,
  }) {
    return TrainingLoaded(
      deviceConnection: clearDeviceConnection ? null : deviceConnection ?? this.deviceConnection,
      activeSession: clearActiveSession ? null : activeSession ?? this.activeSession,
      isMonitoring: isMonitoring ?? this.isMonitoring,
      currentReading: currentReading ?? this.currentReading,
      selectedPosition: selectedPosition ?? this.selectedPosition,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      soundVolume: soundVolume ?? this.soundVolume,
      levelDisplayVisible: levelDisplayVisible ?? this.levelDisplayVisible,
      availableDevices: availableDevices ?? this.availableDevices,
      isScanning: isScanning ?? this.isScanning,
      isCalibrating: isCalibrating ?? this.isCalibrating,
      sessionStats: sessionStats ?? this.sessionStats,
      isConnecting: isConnecting ?? this.isConnecting,
      isStartingMonitoring: isStartingMonitoring ?? this.isStartingMonitoring,
      bluetoothSetupResult: bluetoothSetupResult ?? this.bluetoothSetupResult,
      hasActiveLoadout: hasActiveLoadout ?? this.hasActiveLoadout,
      isLoadingLoadoutStatus: isLoadingLoadoutStatus ?? this.isLoadingLoadoutStatus,
      customCantTolerance: customCantTolerance ?? this.customCantTolerance,
      customTiltTolerance: customTiltTolerance ?? this.customTiltTolerance,
      // ✅ NEW: Settings properties
      availableRifles: availableRifles ?? this.availableRifles,
      availableAmmunition: availableAmmunition ?? this.availableAmmunition,
      availableScopes: availableScopes ?? this.availableScopes,
      loadoutSelection: loadoutSelection ?? this.loadoutSelection,
      preferences: preferences ?? this.preferences,
      settingsAvailableDevices: settingsAvailableDevices ?? this.settingsAvailableDevices,
      isSettingsScanning: isSettingsScanning ?? this.isSettingsScanning,
      isSaving: isSaving ?? this.isSaving,
      // ✅ NEW: Session Information
      sessionInformation: sessionInformation ?? this.sessionInformation,
    );
  }

  @override
  List<Object?> get props => [
    deviceConnection,
    activeSession,
    isMonitoring,
    currentReading,
    selectedPosition,
    soundEnabled,
    soundVolume,
    levelDisplayVisible,
    availableDevices,
    isScanning,
    isCalibrating,
    sessionStats,
    isConnecting,
    isStartingMonitoring,
    bluetoothSetupResult,
    hasActiveLoadout,
    isLoadingLoadoutStatus,
    customCantTolerance,
    customTiltTolerance,
    // ✅ NEW: Settings properties
    availableRifles,
    availableAmmunition,
    availableScopes,
    loadoutSelection,
    preferences,
    settingsAvailableDevices,
    isSettingsScanning,
    isSaving,
    // ✅ NEW: Session Information
    sessionInformation,
  ];
}

class TrainingError extends TrainingState {
  final String message;

  const TrainingError({required this.message});

  @override
  List<Object> get props => [message];
}