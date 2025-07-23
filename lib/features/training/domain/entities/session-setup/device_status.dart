import 'package:equatable/equatable.dart';

class DeviceStatus extends Equatable {
  final String? deviceId;
  final String? deviceName;
  final bool isConnected;
  final int? batteryLevel;
  final String? firmwareVersion;
  final String? signalStrength;

  const DeviceStatus({
    this.deviceId,
    this.deviceName,
    required this.isConnected,
    this.batteryLevel,
    this.firmwareVersion,
    this.signalStrength,
  });

  factory DeviceStatus.disconnected() {
    return const DeviceStatus(isConnected: false);
  }

  factory DeviceStatus.connected({
    required String deviceId,
    required String deviceName,
    required int batteryLevel,
    required String firmwareVersion,
    required String signalStrength,
  }) {
    return DeviceStatus(
      deviceId: deviceId,
      deviceName: deviceName,
      isConnected: true,
      batteryLevel: batteryLevel,
      firmwareVersion: firmwareVersion,
      signalStrength: signalStrength,
    );
  }

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