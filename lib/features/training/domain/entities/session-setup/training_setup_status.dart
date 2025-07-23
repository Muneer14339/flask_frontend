import 'package:equatable/equatable.dart';

class TrainingSetupStatus extends Equatable {
  final bool hasActiveLoadout;
  final bool hasDeviceConnected;
  final bool isTrainingReady;
  final String? activeRifleId;
  final String? activeAmmoId;
  final String? activeScopeId;

  const TrainingSetupStatus({
    required this.hasActiveLoadout,
    required this.hasDeviceConnected,
    required this.isTrainingReady,
    this.activeRifleId,
    this.activeAmmoId,
    this.activeScopeId,
  });

  @override
  List<Object?> get props => [
    hasActiveLoadout,
    hasDeviceConnected,
    isTrainingReady,
    activeRifleId,
    activeAmmoId,
    activeScopeId,
  ];
}