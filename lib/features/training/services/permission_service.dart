// lib/core/services/permission_service.dart
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:location/location.dart';

class PermissionService {
  static final Location _location = Location();

  /// Complete status check for Bluetooth functionality
  static Future<BluetoothStatus> getBluetoothStatus() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return BluetoothStatus.unsupported;
    }

    try {
      // 1. Check if Bluetooth adapter is available and enabled
      final isSupported = await FlutterBluePlus.isSupported;
      if (!isSupported) {
        return BluetoothStatus.unsupported;
      }

      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        return BluetoothStatus.disabled;
      }

      // 2. Check Location services (required for Bluetooth scanning on Android)
      final locationStatus = await getLocationStatus();
      if (locationStatus != LocationStatus.enabled) {
        return BluetoothStatus.locationDisabled;
      }

      // 3. Check permissions
      final permissionStatus = await getPermissionStatus();
      if (permissionStatus != PermissionCheckResult.granted) {
        return BluetoothStatus.permissionsDenied;
      }

      return BluetoothStatus.ready;
    } catch (e) {
      print('Error checking Bluetooth status: $e');
      return BluetoothStatus.error;
    }
  }

  /// Check Location services status
  static Future<LocationStatus> getLocationStatus() async {
    try {
      final isEnabled = await _location.serviceEnabled();
      return isEnabled ? LocationStatus.enabled : LocationStatus.disabled;
    } catch (e) {
      print('Error checking location status: $e');
      return LocationStatus.error;
    }
  }

  /// Check all required permissions
  static Future<PermissionCheckResult> getPermissionStatus() async {
    if (!Platform.isAndroid) {
      return PermissionCheckResult.granted;
    }

    try {
      final permissions = await _getRequiredPermissions();

      for (Permission permission in permissions) {
        final status = await permission.status;
        if (status.isPermanentlyDenied) {
          return PermissionCheckResult.permanentlyDenied;
        } else if (!status.isGranted) {
          return PermissionCheckResult.denied;
        }
      }

      return PermissionCheckResult.granted;
    } catch (e) {
      print('Error checking permissions: $e');
      return PermissionCheckResult.error;
    }
  }

  /// Enable Bluetooth (request user to enable)
  static Future<bool> enableBluetooth() async {
    try {
      if (Platform.isAndroid) {
        // On Android, request user to enable Bluetooth
        await FlutterBluePlus.turnOn();
        return true;
      } else {
        // On iOS, user needs to enable manually via settings
        return false;
      }
    } catch (e) {
      print('Error enabling Bluetooth: $e');
      return false;
    }
  }

  /// Enable Location services (request user to enable)
  static Future<bool> enableLocation() async {
    try {
      return await _location.requestService();
    } catch (e) {
      print('Error enabling location: $e');
      return false;
    }
  }

  /// Request all required permissions
  static Future<PermissionRequestResult> requestPermissions() async {
    if (!Platform.isAndroid) {
      return PermissionRequestResult.granted;
    }

    try {
      final permissions = await _getRequiredPermissions();
      final statuses = await permissions.request();

      bool allGranted = true;
      bool anyPermanentlyDenied = false;

      for (Permission permission in permissions) {
        final status = statuses[permission] ?? await permission.status;

        if (status.isPermanentlyDenied) {
          anyPermanentlyDenied = true;
        } else if (!status.isGranted) {
          allGranted = false;
        }
      }

      if (anyPermanentlyDenied) {
        return PermissionRequestResult.permanentlyDenied;
      } else if (allGranted) {
        return PermissionRequestResult.granted;
      } else {
        return PermissionRequestResult.denied;
      }
    } catch (e) {
      print('Error requesting permissions: $e');
      return PermissionRequestResult.error;
    }
  }

  /// Complete setup process - checks and enables everything needed
  static Future<BluetoothSetupResult> setupBluetooth() async {
    try {
      print('🔍 Starting Bluetooth setup process...');

      // Step 1: Check Bluetooth adapter
      final isSupported = await FlutterBluePlus.isSupported;
      if (!isSupported) {
        return BluetoothSetupResult.unsupported();
      }

      // Step 2: Check if Bluetooth is enabled
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        print('📱 Bluetooth is disabled, requesting enable...');
        return BluetoothSetupResult.bluetoothDisabled();
      }

      // Step 3: Check Location services
      final locationEnabled = await _location.serviceEnabled();
      if (!locationEnabled) {
        print('📍 Location services disabled');
        return BluetoothSetupResult.locationDisabled();
      }

      // Step 4: Check permissions
      final permissionResult = await getPermissionStatus();
      if (permissionResult != PermissionCheckResult.granted) {
        print('🔒 Permissions not granted: $permissionResult');
        return BluetoothSetupResult.permissionsNeeded(permissionResult);
      }

      print('✅ Bluetooth setup complete - all requirements met');
      return BluetoothSetupResult.ready();

    } catch (e) {
      print('❌ Error in Bluetooth setup: $e');
      return BluetoothSetupResult.error(e.toString());
    }
  }

  /// Get required permissions based on Android API level
  static Future<List<Permission>> _getRequiredPermissions() async {
    if (!Platform.isAndroid) return [];

    // For Android 12+ (API 31+), we need new permissions
    final androidInfo = await _getAndroidApiLevel();

    if (androidInfo >= 31) {
      return [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ];
    } else {
      return [
        Permission.bluetooth,
        Permission.location,
        Permission.locationWhenInUse,
      ];
    }
  }

  /// Get Android API level
  static Future<int> _getAndroidApiLevel() async {
    if (!Platform.isAndroid) return 0;

    try {
      const platform = MethodChannel('flutter.native/helper');
      final result = await platform.invokeMethod('getApiLevel');
      return result ?? 30; // Default to API 30 if unable to determine
    } catch (e) {
      return 30; // Default fallback
    }
  }

  /// Open app settings
  static Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// Get user-friendly error messages
  static String getStatusMessage(BluetoothStatus status) {
    switch (status) {
      case BluetoothStatus.ready:
        return 'Bluetooth is ready for device scanning';
      case BluetoothStatus.disabled:
        return 'Please enable Bluetooth to connect to your RifleAxis device';
      case BluetoothStatus.locationDisabled:
        return 'Please enable Location services for Bluetooth scanning';
      case BluetoothStatus.permissionsDenied:
        return 'Please grant the required permissions';
      case BluetoothStatus.unsupported:
        return 'Bluetooth is not supported on this device';
      case BluetoothStatus.error:
        return 'Error checking Bluetooth status';
    }
  }
}

// Enums for better type safety
enum BluetoothStatus {
  ready,
  disabled,
  locationDisabled,
  permissionsDenied,
  unsupported,
  error,
}

enum LocationStatus {
  enabled,
  disabled,
  error,
}

enum PermissionCheckResult {
  granted,
  denied,
  permanentlyDenied,
  error,
}

enum PermissionRequestResult {
  granted,
  denied,
  permanentlyDenied,
  error,
}

// Result classes for better error handling
class BluetoothSetupResult {
  final BluetoothSetupStatus status;
  final String? message;
  final PermissionCheckResult? permissionResult;

  const BluetoothSetupResult._(this.status, {this.message, this.permissionResult});

  factory BluetoothSetupResult.ready() =>
      const BluetoothSetupResult._(BluetoothSetupStatus.ready);

  factory BluetoothSetupResult.bluetoothDisabled() =>
      const BluetoothSetupResult._(BluetoothSetupStatus.bluetoothDisabled);

  factory BluetoothSetupResult.locationDisabled() =>
      const BluetoothSetupResult._(BluetoothSetupStatus.locationDisabled);

  factory BluetoothSetupResult.permissionsNeeded(PermissionCheckResult result) =>
      BluetoothSetupResult._(BluetoothSetupStatus.permissionsNeeded, permissionResult: result);

  factory BluetoothSetupResult.unsupported() =>
      const BluetoothSetupResult._(BluetoothSetupStatus.unsupported);

  factory BluetoothSetupResult.error(String message) =>
      BluetoothSetupResult._(BluetoothSetupStatus.error, message: message);

  bool get isReady => status == BluetoothSetupStatus.ready;
  bool get needsBluetooth => status == BluetoothSetupStatus.bluetoothDisabled;
  bool get needsLocation => status == BluetoothSetupStatus.locationDisabled;
  bool get needsPermissions => status == BluetoothSetupStatus.permissionsNeeded;
}

enum BluetoothSetupStatus {
  ready,
  bluetoothDisabled,
  locationDisabled,
  permissionsNeeded,
  unsupported,
  error,
}