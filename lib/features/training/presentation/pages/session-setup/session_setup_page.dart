// lib/features/training/presentation/pages/session-setup/session_setup_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rt_tiltcant_accgyro/features/training/presentation/widgets/session-setup/environmental_data_section.dart';
import 'package:rt_tiltcant_accgyro/features/training/presentation/widgets/session_planning_section.dart';

import '../../../../../core/theme/app_theme.dart';

import '../../../services/permission_service.dart';
import '../../bloc/training_bloc.dart';
import '../../bloc/training_event.dart';
import '../../bloc/training_state.dart';
import '../../widgets/animated_loading_overlay.dart';
import '../../widgets/session-setup/device_status_bar.dart';
import '../../widgets/session-setup/action_buttons_section.dart';
import '../../widgets/session-setup/session_control_section.dart';
import '../../widgets/session_status_section.dart';
import '../../widgets/action_controls_section.dart';
import '../../widgets/level_overlay.dart';
import '../../widgets/permission_dialogs.dart';
import '../../widgets/session-setup/loadout_configuration_section.dart';
import '../../widgets/session-setup/training_preferences_section.dart';
import '../training_active_page.dart';

class TrainingPage extends StatefulWidget {
  const TrainingPage({Key? key}) : super(key: key);

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage>
    with WidgetsBindingObserver {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        context.read<TrainingBloc>().add(LoadTrainingData());
        _isInitialized = true;
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        final currentState = context.read<TrainingBloc>().state;
        if (currentState is TrainingLoaded) {
          if (currentState.isMonitoring && !currentState.isSessionActive) {
            context.read<TrainingBloc>().add(StopMonitoringEvent());
          }
        }
        break;
      case AppLifecycleState.resumed:
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: BlocConsumer<TrainingBloc, TrainingState>(
          listener: (context, state) {
            // Handle Bluetooth setup status changes
            if (state is TrainingLoaded && state.bluetoothSetupResult != null) {
              _handleBluetoothSetupResult(context, state.bluetoothSetupResult!);
            }

            if (state is TrainingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.danger,
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: 'Dismiss',
                    textColor: Colors.white,
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is TrainingLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Initializing Training System...',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is TrainingLoaded) {
              return Stack(
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    margin: const EdgeInsets.symmetric(horizontal: 0),
                    child: Column(
                      children: [
                        // Header with Save Button
                        Container(
                          width: double.infinity,
                          color: AppTheme.primary,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'RifleAxis Training',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Barlow Condensed',
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: !state.isSaving
                                        ? () {
                                      context.read<TrainingBloc>().add(SaveAllSettingsEvent());
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Settings saved successfully!'),
                                          backgroundColor: AppTheme.success,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.success,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      minimumSize: Size.zero,
                                    ),
                                    child: state.isSaving
                                        ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                        : const Text(
                                      'Save Settings',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                              if (state.isMonitoring)
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Live Sensor Data',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Scrollable Content
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              children: [
                                // ✅ UPDATED: Device Status Bar with completion tracking
                                DeviceStatusBar(
                                  deviceConnection: state.deviceConnection,
                                  hasActiveLoadout: state.hasActiveLoadout,
                                  isLoadingLoadoutStatus: state.isLoadingLoadoutStatus,
                                  isDeviceConnectionComplete: state.isDeviceConnectionComplete, // ✅ NEW
                                  onDeviceAction: () => _showDeviceActionDialog(context),
                                  onActivateLoadout: () => Navigator.pushNamed(context, '/Loadout'),
                                ),

                                // ✅ UPDATED: Loadout Configuration Section with filtering
                                LoadoutConfigurationSection(
                                  loadoutSelection: state.loadoutSelection,
                                  availableRifles: state.availableRifles,
                                  availableRiflesWithAmmo: state.availableRiflesWithAmmo, // ✅ NEW
                                  availableRiflesWithoutAmmo: state.availableRiflesWithoutAmmo, // ✅ NEW
                                  activeRifle: state.activeRifle,
                                  isCompleted: state.isLoadoutConfigurationComplete, // ✅ NEW
                                  onManageLoadout: () => Navigator.pushNamed(context, '/Loadout'),
                                ),

                                // ✅ UPDATED: Session Control with completion tracking
                                SessionInformationSection(
                                  sessionInformation: state.sessionInformation, // ✅ NEW
                                  isCompleted: state.isSessionInformationComplete, // ✅ NEW
                                ),

                                // ✅ NEW: Training Preferences Section with completion indicator
                                TrainingPreferencesSection(
                                  preferences: state.preferences,
                                  onSoundEnabledChanged: (enabled) {
                                    context.read<TrainingBloc>().add(UpdateSoundEnabledEvent(enabled: enabled));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Sound alerts ${enabled ? 'enabled' : 'disabled'}'),
                                        backgroundColor: AppTheme.primary,
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  onVolumeChanged: (volume) =>
                                      context.read<TrainingBloc>().add(UpdateSoundVolumeEvent(volume: volume)),
                                  onAlertToneChanged: (tone) =>
                                      context.read<TrainingBloc>().add(UpdateAlertToneEvent(alertTone: tone)),
                                  onTestSound: (tone) {
                                    context.read<TrainingBloc>().add(TestSoundEvent(alertTone: tone));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Testing $tone sound'),
                                        backgroundColor: AppTheme.warning,
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                ),

                                EnvironmentalDataSection(),
                                SessionPlanningSection(),

                                // Session Status (appears when session is active)
                                if (state.isSessionActive)
                                  SessionStatusSection(
                                    session: state.activeSession!,
                                    sessionStats: state.sessionStats,
                                  ),

                                // ✅ UPDATED: Action Controls with dynamic completion
                                ActionButtonsSection(
                                  completedSections: state.completedSections, // ✅ NOW DYNAMIC
                                  sectionCompletions: state.sectionCompletions, // ✅ NEW: Section-wise status
                                  onSaveAsTemplate: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Template saved successfully!'),
                                        backgroundColor: AppTheme.success,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  onStartSession: () {
                                    // ✅ Pass all session data to TrainingActivePage
                                    _startMonitoringAndNavigateWithData(context, state);
                                  },
                                )

                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Level Overlay
                  if (state.levelDisplayVisible)
                    LevelOverlay(
                      currentReading: state.currentReading,
                      selectedPosition: state.currentPositionWithCustomValues,
                      onClose: () =>
                          context.read<TrainingBloc>().add(HideLevelDisplay()),
                    ),

                  AnimatedLoadingOverlay(
                    message: 'Connecting to device\nplease wait',
                    isVisible: state.isConnecting,
                  ),

                  AnimatedLoadingOverlay(
                    message: 'Starting monitoring\nkeep device steady',
                    isVisible: state.isStartingMonitoring,
                  ),

                  AnimatedLoadingOverlay(
                    message: 'Calibrating device\nkeep steady',
                    isVisible: state.isCalibrating,
                  ),
                ],
              );
            }

            if (state is TrainingError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppTheme.danger,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Training System Error',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.danger,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<TrainingBloc>().add(LoadTrainingData());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading Training System...',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ✅ NEW: Training Preferences with completion indicator
  Widget _buildTrainingPreferencesSection(TrainingLoaded state) {
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
          // Header with optional indicator (always completed for preferences)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Training Preferences',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.success, // Always completed
                ),
                child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Preferences content
          TrainingPreferencesSection(
            preferences: state.preferences,
            onSoundEnabledChanged: (enabled) {
              context.read<TrainingBloc>().add(UpdateSoundEnabledEvent(enabled: enabled));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sound alerts ${enabled ? 'enabled' : 'disabled'}'),
                  backgroundColor: AppTheme.primary,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            onVolumeChanged: (volume) =>
                context.read<TrainingBloc>().add(UpdateSoundVolumeEvent(volume: volume)),
            onAlertToneChanged: (tone) =>
                context.read<TrainingBloc>().add(UpdateAlertToneEvent(alertTone: tone)),
            onTestSound: (tone) {
              context.read<TrainingBloc>().add(TestSoundEvent(alertTone: tone));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Testing $tone sound'),
                  backgroundColor: AppTheme.warning,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ✅ NEW: Start monitoring and navigate with all session data
  void _startMonitoringAndNavigateWithData(BuildContext context, TrainingLoaded state) {
    // Check if minimum requirements are met
    if (state.completedSections < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete device connection, loadout configuration, and session information first'),
          backgroundColor: AppTheme.warning,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Start monitoring
    context.read<TrainingBloc>().add(StartMonitoringEvent());

    // Navigate to active training page with all data
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TrainingActivePage(),
        // ✅ Pass session data as route arguments if needed
        settings: RouteSettings(
          arguments: {
            'sessionInformation': state.sessionInformation,
            'loadoutSelection': state.loadoutSelection,
            'activeRifle': state.activeRifle,
            'preferences': state.preferences,
          },
        ),
      ),
    );
  }

  // ✅ Start session and navigate to active screen
  void _startSessionAndNavigate(BuildContext context) {
    _showQuickSessionDialog(context, navigateAfter: true);
  }

  // Handle comprehensive Bluetooth setup results
  void _handleBluetoothSetupResult(
      BuildContext context, BluetoothSetupResult result) {
    final currentState = context.read<TrainingBloc>().state;
    if (currentState is TrainingLoaded) {
      if (currentState.isScanning || currentState.isDeviceConnected) {
        return;
      }
    }

    if (!result.isReady) {
      PermissionDialogs.showBluetoothSetupDialog(context, result)
          .then((userAction) {
        if (userAction == true) {
          _handleUserSetupAction(context, result);
        }
      });
    }
  }

  // Handle user actions from setup dialogs
  void _handleUserSetupAction(
      BuildContext context, BluetoothSetupResult result) {
    switch (result.status) {
      case BluetoothSetupStatus.bluetoothDisabled:
        PermissionDialogs.showEnablingDialog(context, 'Bluetooth');
        context.read<TrainingBloc>().add(EnableBluetooth());
        Future.delayed(const Duration(seconds: 1), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });
        break;

      case BluetoothSetupStatus.locationDisabled:
        PermissionDialogs.showEnablingDialog(context, 'Location Services');
        context.read<TrainingBloc>().add(EnableLocation());
        Future.delayed(const Duration(seconds: 1), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });
        break;

      case BluetoothSetupStatus.permissionsNeeded:
        if (result.permissionResult ==
            PermissionCheckResult.permanentlyDenied) {
          openAppSettings();
        } else {
          context.read<TrainingBloc>().add(RequestPermissions());
        }
        break;

      case BluetoothSetupStatus.error:
        context.read<TrainingBloc>().add(RetrySetup());
        break;

      default:
        break;
    }
  }

  void _showDeviceActionDialog(BuildContext context) {
    final state = context.read<TrainingBloc>().state;
    if (state is! TrainingLoaded) return;

    if (state.isDeviceConnected) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
              'Device: ${state.deviceConnection?.deviceName ?? 'Unknown'}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.deviceConnection != null) ...[
                ListTile(
                  leading: const Icon(Icons.battery_std),
                  title:
                  Text('Battery: ${state.deviceConnection!.batteryLevel}%'),
                  dense: true,
                ),
                ListTile(
                  leading: const Icon(Icons.signal_cellular_alt),
                  title:
                  Text('Signal: ${state.deviceConnection!.signalStrength}'),
                  dense: true,
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: Text(
                      'Firmware: ${state.deviceConnection!.firmwareVersion}'),
                  dense: true,
                ),
                const Divider(),
              ],
              ListTile(
                leading: const Icon(Icons.bluetooth_disabled),
                title: const Text('Disconnect'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<TrainingBloc>().add(DisconnectDevice());
                },
              ),
            ],
          ),
        ),
      );
    } else {
      _showDevicePairingDialog(context);
    }
  }

  // Device pairing dialog with comprehensive setup
  void _showDevicePairingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.bluetooth_searching, color: AppTheme.primary),
            const SizedBox(width: 8),
            const Text(
              'Pair Device',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pairing Instructions:'),
            const SizedBox(height: 8),
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
                  Text(
                      '1. Ensure your RifleAxis device is charged and powered on'),
                  Text(
                      '2. Hold the pairing button for 3 seconds until LED flashes blue'),
                  Text('3. Click "Scan for Devices" below'),
                  Text('4. Select your device from the list when it appears'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<TrainingBloc, TrainingState>(
              builder: (context, state) {
                if (state is! TrainingLoaded)
                  return const Center(child: CircularProgressIndicator());

                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: state.isScanning
                            ? null
                            : () {
                          context
                              .read<TrainingBloc>()
                              .add(SetupBluetooth());
                        },
                        icon: state.isScanning
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white)),
                        )
                            : const Icon(Icons.bluetooth_searching),
                        label: Text(state.isScanning
                            ? 'Scanning...'
                            : 'Scan for Devices'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),

                    // Show setup status if available
                    if (state.bluetoothSetupResult != null &&
                        !state.bluetoothSetupResult!.isReady) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                color: AppTheme.warning, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                PermissionService.getStatusMessage(
                                    _getBluetoothStatusFromSetupResult(
                                        state.bluetoothSetupResult!)),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.warning,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (state.availableDevices.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.devices,
                              color: AppTheme.primary, size: 16),
                          const SizedBox(width: 8),
                          const Text(
                            'Available Devices:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: state.availableDevices.length,
                          itemBuilder: (context, index) {
                            final device = state.availableDevices[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.borderColor),
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.bluetooth,
                                    color: AppTheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          device,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const Text(
                                          'RifleAxis Device',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      context.read<TrainingBloc>().add(
                                        ConnectToDevice(deviceId: device),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.success,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      minimumSize: Size.zero,
                                    ),
                                    child: const Text('Connect'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Helper method to convert setup result to status for message
  BluetoothStatus _getBluetoothStatusFromSetupResult(
      BluetoothSetupResult result)
  {
    switch (result.status) {
      case BluetoothSetupStatus.ready:
        return BluetoothStatus.ready;
      case BluetoothSetupStatus.bluetoothDisabled:
        return BluetoothStatus.disabled;
      case BluetoothSetupStatus.locationDisabled:
        return BluetoothStatus.locationDisabled;
      case BluetoothSetupStatus.permissionsNeeded:
        return BluetoothStatus.permissionsDenied;
      case BluetoothSetupStatus.unsupported:
        return BluetoothStatus.unsupported;
      case BluetoothSetupStatus.error:
        return BluetoothStatus.error;
    }
  }

  void _showCalibrationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calibrate Sensors'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Calibration Instructions:'),
            SizedBox(height: 8),
            Text('1. Place the rifle in your desired "zero" position'),
            Text('2. Ensure the rifle is stable and not moving'),
            Text('3. Click "Start Calibration" below'),
            Text('4. Keep the rifle steady during calibration'),
            SizedBox(height: 16),
            Text(
                'This will set the current position as your reference point (0°, 0°).'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TrainingBloc>().add(CalibrateSensorsEvent());
            },
            child: const Text('Start Calibration'),
          ),
        ],
      ),
    );
  }

  void _showQuickSessionDialog(BuildContext context, {bool navigateAfter = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Quick Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Start a quick training session with default settings?'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _startSession(context, {
                        'name': 'Quick Training',
                        'type': 'dry-fire',
                        'notes': '',
                      });

                      if (navigateAfter) {
                        Future.delayed(const Duration(milliseconds: 500), () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const TrainingActivePage(),
                            ),
                          );
                        });
                      }
                    },
                    child: const Text('Start'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _startSession(BuildContext context, Map<String, dynamic> sessionData) {
    context.read<TrainingBloc>().add(
      StartSessionEvent(
        sessionName: sessionData['name'] ?? 'Training Session',
        sessionType: sessionData['type'] ?? 'dry-fire',
        notes: sessionData['notes'],
        weather: sessionData['weather'],
        windSpeed: sessionData['windSpeed'],
        temperature: sessionData['temperature'],
        humidity: sessionData['humidity'],
      ),
    );
  }
}