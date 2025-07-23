// lib/features/training/presentation/bloc/training_event.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/training_session.dart';
import '../../domain/entities/position_preset.dart';
import '../../domain/entities/session-setup/training_preferences.dart';

abstract class TrainingEvent extends Equatable {
  const TrainingEvent();

  @override
  List<Object?> get props => [];
}

class LoadTrainingData extends TrainingEvent {}

// ✅ NEW: Load loadout status
class LoadLoadoutStatus extends TrainingEvent {}

class ConnectToDevice extends TrainingEvent {
  final String deviceId;

  const ConnectToDevice({required this.deviceId});

  @override
  List<Object> get props => [deviceId];
}

class DisconnectDevice extends TrainingEvent {}

class ScanForDevices extends TrainingEvent {}

class StartMonitoringEvent extends TrainingEvent {}

class StopMonitoringEvent extends TrainingEvent {}

class StartSessionEvent extends TrainingEvent {
  final String sessionName;
  final String sessionType;
  final String? notes;
  final String? weather;
  final double? windSpeed;
  final double? temperature;
  final double? humidity;

  const StartSessionEvent({
    required this.sessionName,
    required this.sessionType,
    this.notes,
    this.weather,
    this.windSpeed,
    this.temperature,
    this.humidity,
  });

  @override
  List<Object?> get props => [
    sessionName,
    sessionType,
    notes,
    weather,
    windSpeed,
    temperature,
    humidity,
  ];
}

class EndSessionEvent extends TrainingEvent {}

class CalibrateSensorsEvent extends TrainingEvent {}

class ChangePositionPreset extends TrainingEvent {
  final PositionPreset preset;

  const ChangePositionPreset({required this.preset});

  @override
  List<Object> get props => [preset];
}

// Custom tolerance events
class UpdateCustomCantTolerance extends TrainingEvent {
  final double cantTolerance;

  const UpdateCustomCantTolerance({required this.cantTolerance});

  @override
  List<Object> get props => [cantTolerance];
}

class UpdateCustomTiltTolerance extends TrainingEvent {
  final double tiltTolerance;

  const UpdateCustomTiltTolerance({required this.tiltTolerance});

  @override
  List<Object> get props => [tiltTolerance];
}

class ResetCustomTolerances extends TrainingEvent {}

class ToggleSoundAlerts extends TrainingEvent {}

class UpdateSoundVolume extends TrainingEvent {
  final double volume;

  const UpdateSoundVolume({required this.volume});

  @override
  List<Object> get props => [volume];
}

class ShowLevelDisplay extends TrainingEvent {}

class HideLevelDisplay extends TrainingEvent {}

class AngleReadingReceived extends TrainingEvent {
  final double cant;
  final double tilt;
  final double pan;

  const AngleReadingReceived({
    required this.cant,
    required this.tilt,
    required this.pan,
  });

  @override
  List<Object> get props => [cant, tilt, pan];
}

// Enhanced setup events for comprehensive Bluetooth handling
class SetupBluetooth extends TrainingEvent {}

class EnableBluetooth extends TrainingEvent {}

class EnableLocation extends TrainingEvent {}

class RequestPermissions extends TrainingEvent {}

class RetrySetup extends TrainingEvent {}

class OpenAppSettings extends TrainingEvent {}

// ✅ NEW: Settings Events (merged from SettingsEvent)
class SetActiveRifleEvent extends TrainingEvent {
  final String rifleId;

  const SetActiveRifleEvent({required this.rifleId});

  @override
  List<Object> get props => [rifleId];
}

// ✅ NEW: Clear Active Rifle Event
class ClearActiveRifleEvent extends TrainingEvent {}

class UpdateSoundEnabledEvent extends TrainingEvent {
  final bool enabled;

  const UpdateSoundEnabledEvent({required this.enabled});

  @override
  List<Object> get props => [enabled];
}

class UpdateSoundVolumeEvent extends TrainingEvent {
  final double volume;

  const UpdateSoundVolumeEvent({required this.volume});

  @override
  List<Object> get props => [volume];
}

class UpdateAlertToneEvent extends TrainingEvent {
  final String alertTone;

  const UpdateAlertToneEvent({required this.alertTone});

  @override
  List<Object> get props => [alertTone];
}

class TestSoundEvent extends TrainingEvent {
  final String alertTone;

  const TestSoundEvent({required this.alertTone});

  @override
  List<Object> get props => [alertTone];
}

class SaveAllSettingsEvent extends TrainingEvent {}

// ✅ NEW: Session Information Events
class UpdateSessionNameEvent extends TrainingEvent {
  final String sessionName;

  const UpdateSessionNameEvent({required this.sessionName});

  @override
  List<Object> get props => [sessionName];
}

class UpdateSessionTypeEvent extends TrainingEvent {
  final String sessionType;

  const UpdateSessionTypeEvent({required this.sessionType});

  @override
  List<Object> get props => [sessionType];
}

class UpdateSessionDateEvent extends TrainingEvent {
  final DateTime date;

  const UpdateSessionDateEvent({required this.date});

  @override
  List<Object> get props => [date];
}

class UpdateSessionTimeEvent extends TrainingEvent {
  final TimeOfDay time;

  const UpdateSessionTimeEvent({required this.time});

  @override
  List<Object> get props => [time];
}

class UpdateShootingPositionEvent extends TrainingEvent {
  final String shootingPosition;

  const UpdateShootingPositionEvent({required this.shootingPosition});

  @override
  List<Object> get props => [shootingPosition];
}

class UpdateDistanceEvent extends TrainingEvent {
  final String distance;

  const UpdateDistanceEvent({required this.distance});

  @override
  List<Object> get props => [distance];
}

class ClearSessionInformationEvent extends TrainingEvent {}