import 'package:equatable/equatable.dart';

class AvailableDevice extends Equatable {
  final String deviceId;
  final String deviceName;
  final String signalStrength;

  const AvailableDevice({
    required this.deviceId,
    required this.deviceName,
    required this.signalStrength,
  });

  @override
  List<Object> get props => [deviceId, deviceName, signalStrength];
}