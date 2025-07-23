// lib/features/settings/presentation/widgets/device_connection_section.dart
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/session-setup/device_status.dart';
import '../../../domain/entities/session-setup/available_device.dart';

class DeviceConnectionSection extends StatelessWidget {
  final DeviceStatus deviceStatus;
  final List<AvailableDevice> availableDevices;
  final bool isScanning;
  final VoidCallback onScanDevices;
  final Function(String) onConnectDevice;
  final VoidCallback onDisconnectDevice;

  const DeviceConnectionSection({
    Key? key,
    required this.deviceStatus,
    required this.availableDevices,
    required this.isScanning,
    required this.onScanDevices,
    required this.onConnectDevice,
    required this.onDisconnectDevice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              const Icon(Icons.bluetooth, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'RifleAxis Device',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: deviceStatus.isConnected ? AppTheme.success : AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                deviceStatus.isConnected ? 'Connected' : 'Disconnected',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: deviceStatus.isConnected ? AppTheme.success : AppTheme.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Device Content
          if (deviceStatus.isConnected) ...[
            // ✅ Connected Device Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: const Border(
                  left: BorderSide(color: AppTheme.success, width: 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deviceStatus.deviceName ?? 'Unknown Device',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Device Stats Row
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.battery_std,
                            size: 16,
                            color: _getBatteryColor(deviceStatus.batteryLevel ?? 0),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Battery: ${deviceStatus.batteryLevel ?? 0}%',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getSignalIcon(deviceStatus.signalStrength ?? 'Weak'),
                            size: 16,
                            color: _getSignalColor(deviceStatus.signalStrength ?? 'Weak'),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Signal: ${deviceStatus.signalStrength ?? 'Unknown'}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.memory, size: 16, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            'v${deviceStatus.firmwareVersion ?? 'Unknown'}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ✅ Disconnect Button Only (Removed Settings Button)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onDisconnectDevice,
                      icon: const Icon(Icons.bluetooth_disabled, size: 18),
                      label: const Text('Disconnect Device'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // ✅ Not Connected - Pairing Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppTheme.primary, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Device Pairing',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Pairing Instructions
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1. Power on your RifleAxis device',
                        style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '2. Hold pairing button until LED flashes blue',
                        style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '3. Tap "Scan for Devices" below',
                        style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ✅ Scan Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isScanning ? null : onScanDevices,
                      icon: isScanning
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Icon(Icons.bluetooth_searching, size: 18),
                      label: Text(isScanning ? 'Scanning...' : 'Scan for Devices'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ),

                  // ✅ Available Devices List (With Signal Icons)
                  if (availableDevices.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.devices,
                            color: AppTheme.primary,
                            size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'Available Devices',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...availableDevices.map(
                          (device) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.radio_button_unchecked,
                              color: _getSignalColor(device.signalStrength),
                              size: 16,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    device.deviceName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Signal: ${device.signalStrength}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => onConnectDevice(device.deviceId),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.success,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                minimumSize: Size.zero,
                              ),
                              child: const Text(
                                'Connect',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ✅ Helper Methods for Signal Icons and Colors
  Color _getBatteryColor(int batteryLevel) {
    if (batteryLevel > 50) return AppTheme.success;
    if (batteryLevel > 20) return AppTheme.warning;
    return AppTheme.accent;
  }

  IconData _getSignalIcon(String signalStrength) {
    switch (signalStrength.toLowerCase()) {
      case 'strong':
        return Icons.signal_cellular_4_bar;
      case 'good':
      case 'medium':
        return Icons.signal_cellular_alt_2_bar;
      case 'weak':
        return Icons.signal_cellular_alt_1_bar;
      default:
        return Icons.signal_cellular_off;
    }
  }

  Color _getSignalColor(String signalStrength) {
    switch (signalStrength.toLowerCase()) {
      case 'strong':
        return AppTheme.success;
      case 'good':
      case 'medium':
        return AppTheme.warning;
      case 'weak':
        return AppTheme.accent;
      default:
        return AppTheme.textSecondary;
    }
  }
}