// lib/features/training/presentation/widgets/permission_dialogs.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../services/permission_service.dart';

class PermissionDialogs {

  /// Show comprehensive setup dialog based on status
  static Future<bool?> showBluetoothSetupDialog(
      BuildContext context,
      BluetoothSetupResult result
      ) {
    switch (result.status) {
      case BluetoothSetupStatus.bluetoothDisabled:
        return _showBluetoothDisabledDialog(context);

      case BluetoothSetupStatus.locationDisabled:
        return _showLocationDisabledDialog(context);

      case BluetoothSetupStatus.permissionsNeeded:
        return _showPermissionRequestDialog(context, result.permissionResult!);

      case BluetoothSetupStatus.unsupported:
        return _showUnsupportedDialog(context);

      case BluetoothSetupStatus.error:
        return _showErrorDialog(context, result.message ?? 'Unknown error');

      case BluetoothSetupStatus.ready:
        return Future.value(true); // Already ready
    }
  }

  /// Show Bluetooth disabled dialog with enable option
  static Future<bool?> _showBluetoothDisabledDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.bluetooth_disabled,
                color: AppTheme.warning,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Bluetooth Required',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.warning,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bluetooth is currently disabled. RifleAxis needs Bluetooth to:',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            _buildFeatureList([
              'Connect to your RifleAxis training device',
              'Receive real-time sensor data',
              'Maintain stable connection during training',
            ]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.info.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.info, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tap "Enable Bluetooth" to automatically turn on Bluetooth.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.info,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondary),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(context).pop(true);
              // Enable Bluetooth will be handled by the caller
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warning,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            icon: const Icon(Icons.bluetooth, size: 18),
            label: const Text('Enable Bluetooth'),
          ),
        ],
      ),
    );
  }

  /// Show Location services disabled dialog
  static Future<bool?> _showLocationDisabledDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.location_off,
                color: AppTheme.accent,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Location Services Required',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accent,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location services are disabled. Android requires location access for Bluetooth device scanning.',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.security, color: AppTheme.primary, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Privacy Protection:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'RifleAxis only uses location for Bluetooth scanning. Your location data is never collected or stored.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.primary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondary),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(context).pop(true);
              // Enable Location will be handled by the caller
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            icon: const Icon(Icons.location_on, size: 18),
            label: const Text('Enable Location'),
          ),
        ],
      ),
    );
  }

  /// Show permission request dialog
  static Future<bool?> _showPermissionRequestDialog(
      BuildContext context,
      PermissionCheckResult currentStatus
      ) {
    final isPermanentlyDenied = currentStatus == PermissionCheckResult.permanentlyDenied;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isPermanentlyDenied ? AppTheme.danger : AppTheme.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isPermanentlyDenied ? Icons.block : Icons.security,
                color: isPermanentlyDenied ? AppTheme.danger : AppTheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isPermanentlyDenied ? 'Settings Required' : 'Permissions Required',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isPermanentlyDenied ? AppTheme.danger : AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isPermanentlyDenied
                  ? 'Some permissions were permanently denied. Please enable them manually in settings:'
                  : 'RifleAxis needs the following permissions to connect to your device:',
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            if (!isPermanentlyDenied) ...[
              // Show permission list
              _buildPermissionList(),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.success.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_user, color: AppTheme.success, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'These permissions are only used for device connectivity. Your privacy is fully protected.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.success,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Show manual steps for permanently denied
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manual Steps:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('1. Tap "Open Settings" below', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                    Text('2. Go to "Permissions"', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                    Text('3. Enable "Location" and "Nearby devices"', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                    Text('4. Return to RifleAxis', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondary),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isPermanentlyDenied ? AppTheme.danger : AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(isPermanentlyDenied ? 'Open Settings' : 'Grant Permissions'),
          ),
        ],
      ),
    );
  }

  /// Show device unsupported dialog
  static Future<bool?> _showUnsupportedDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.device_unknown,
                color: AppTheme.danger,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Device Not Supported',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.danger,
                ),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This device does not support Bluetooth functionality required for RifleAxis training.',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'You can still use the app for Loadout management and viewing training history.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  /// Show error dialog
  static Future<bool?> _showErrorDialog(BuildContext context, String error) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: AppTheme.danger, size: 24),
            SizedBox(width: 12),
            Text(
              'Setup Error',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.danger,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'An error occurred while setting up Bluetooth:',
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                error,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.danger,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  /// Build permission list for dialog
  static Widget _buildPermissionList() {
    final permissions = [
      {
        'icon': Icons.bluetooth_searching,
        'title': 'Bluetooth Scanning',
        'description': 'Find nearby RifleAxis devices',
      },
      {
        'icon': Icons.bluetooth_connected,
        'title': 'Bluetooth Connection',
        'description': 'Connect to your RifleAxis device',
      },
      {
        'icon': Icons.location_on,
        'title': 'Location Access',
        'description': 'Required for Bluetooth scanning on Android',
      },
    ];

    return Column(
      children: permissions.map((permission) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  permission['icon'] as IconData,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      permission['title'] as String,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      permission['description'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Build feature list helper
  static Widget _buildFeatureList(List<String> features) {
    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: AppTheme.success, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  feature,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Show requesting/enabling dialog (loading state)
  static void showEnablingDialog(BuildContext context, String service) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Enabling $service...',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please follow the system prompts',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}