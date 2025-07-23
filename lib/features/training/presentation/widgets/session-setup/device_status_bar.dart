// lib/features/training/presentation/widgets/session-setup/device_status_bar.dart
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/device_connection.dart';

class DeviceStatusBar extends StatelessWidget {
  final DeviceConnection? deviceConnection;
  final bool hasActiveLoadout;
  final bool isLoadingLoadoutStatus;
  final bool isDeviceConnectionComplete; // ✅ NEW: Device completion status
  final VoidCallback onDeviceAction;
  final VoidCallback onActivateLoadout;

  const DeviceStatusBar({
    Key? key,
    this.deviceConnection,
    required this.hasActiveLoadout,
    required this.isLoadingLoadoutStatus,
    required this.isDeviceConnectionComplete, // ✅ NEW
    required this.onDeviceAction,
    required this.onActivateLoadout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isConnected = deviceConnection?.isConnected ?? false;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // ✅ UPDATED: Device Connection Status Row with Section Number
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Device info section
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isConnected ? AppTheme.success : AppTheme.textSecondary,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'RifleAxis Device',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            isConnected
                                ? '${deviceConnection?.deviceName ?? 'Unknown'} • Battery: ${deviceConnection?.batteryLevel}%'
                                : 'Not Connected',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ✅ NEW: Section completion indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDeviceConnectionComplete ? AppTheme.success : AppTheme.borderColor,
                ),
                child: isDeviceConnectionComplete
                    ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16
                )
                    : const Text(
                  '1',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(width: 8),

              ElevatedButton(
                onPressed: onDeviceAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryLight,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                ),
                child: Text(
                  isConnected ? 'Settings' : 'Pair Device',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),

          // ✅ NEW: Training Ready Indicator (only if at least one condition is met)
          if (isConnected || hasActiveLoadout) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppTheme.borderColor),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isConnected && hasActiveLoadout)
                    ? AppTheme.success.withOpacity(0.1)
                    : AppTheme.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (isConnected && hasActiveLoadout)
                      ? AppTheme.success
                      : AppTheme.warning,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    (isConnected && hasActiveLoadout)
                        ? Icons.check_circle
                        : Icons.warning_amber,
                    color: (isConnected && hasActiveLoadout)
                        ? AppTheme.success
                        : AppTheme.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getReadinessMessage(isConnected, hasActiveLoadout),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: (isConnected && hasActiveLoadout)
                            ? AppTheme.success
                            : AppTheme.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getReadinessMessage(bool isConnected, bool hasLoadout) {
    if (isConnected && hasLoadout) {
      return 'Device Ready for Training';
    } else if (isConnected && !hasLoadout) {
      return 'Device connected • Configure loadout to continue';
    } else if (!isConnected && hasLoadout) {
      return 'Loadout ready • Connect device to start training';
    } else {
      return 'Complete setup to start training';
    }
  }
}