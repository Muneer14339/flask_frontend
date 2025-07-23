import 'package:equatable/equatable.dart';

class DeviceConnection extends Equatable {
  final String deviceId;
  final String deviceName;
  final bool isConnected;
  final int batteryLevel;
  final String firmwareVersion;
  final String signalStrength;

  const DeviceConnection({
    required this.deviceId,
    required this.deviceName,
    required this.isConnected,
    required this.batteryLevel,
    required this.firmwareVersion,
    required this.signalStrength,
  });

  @override
  List<Object?> get props => [
    deviceId,
    deviceName,
    isConnected,
    batteryLevel,
    firmwareVersion,
    signalStrength,
  ];
}