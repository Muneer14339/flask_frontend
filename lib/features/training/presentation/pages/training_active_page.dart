// lib/features/training/presentation/pages/training_active_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/training_bloc.dart';
import '../bloc/training_event.dart';
import '../bloc/training_state.dart';
import '../widgets/animated_loading_overlay.dart';
import '../widgets/position_selector.dart';
import '../widgets/angle_metrics_grid.dart';
import '../widgets/action_controls_section.dart';
import '../widgets/level_display_toggle.dart';
import '../widgets/level_overlay.dart';

class TrainingActivePage extends StatefulWidget {
  const TrainingActivePage({Key? key}) : super(key: key);

  @override
  State<TrainingActivePage> createState() => _TrainingActivePageState();
}

class _TrainingActivePageState extends State<TrainingActivePage>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
      // Handle app resume if needed
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Allow back navigation
        return true;
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: BlocConsumer<TrainingBloc, TrainingState>(
            listener: (context, state) {
              // Handle errors
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

              // Auto-navigate back if device disconnects or monitoring stops
              if (state is TrainingLoaded) {
                if (!state.isDeviceConnected || (!state.isMonitoring && !state.isSessionActive)) {
                  // Optional: Auto-navigate back when conditions are not met
                  // Navigator.of(context).pop();
                }
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
                        'Loading Training System...',
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
                          // Header
                          Container(
                            width: double.infinity,
                            color: AppTheme.primary,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      icon: const Icon(
                                        Icons.arrow_back,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Expanded(
                                      child: const Text(
                                        'Training Session',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Barlow Condensed',
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(width: 48), // Balance the back button
                                  ],
                                ),
                                if (state.isMonitoring || state.isSessionActive)
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
                                        Text(
                                          state.isSessionActive
                                              ? 'Active Training Session'
                                              : 'Live Sensor Data',
                                          style: const TextStyle(
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
                                  // Position Selector
                                  PositionSelector(
                                    selectedPosition: state.selectedPosition,
                                    customCantTolerance: state.customCantTolerance,
                                    customTiltTolerance: state.customTiltTolerance,
                                    onPositionChanged: (preset) {
                                      context.read<TrainingBloc>().add(
                                        ChangePositionPreset(preset: preset),
                                      );
                                    },
                                  ),

                                  // Angle Metrics
                                  AngleMetricsGrid(
                                    currentReading: state.currentReading,
                                    selectedPosition: state.currentPositionWithCustomValues,
                                  ),

                                  // Action Controls Section (with same screen behavior)
                                  ActionControlsSection(
                                    isDeviceConnected: state.isDeviceConnected,
                                    hasActiveLoadout: state.hasActiveLoadout,
                                    isMonitoring: !state.isMonitoring,
                                    isSessionActive: state.isSessionActive,
                                    soundEnabled: state.soundEnabled,
                                    isCalibrating: state.isCalibrating,
                                    onStartMonitoring: () => context
                                        .read<TrainingBloc>()
                                        .add(StartMonitoringEvent()),
                                    onStopMonitoring: () => context
                                        .read<TrainingBloc>()
                                        .add(StopMonitoringEvent()),
                                    onEndSession: () => context
                                        .read<TrainingBloc>()
                                        .add(EndSessionEvent()),
                                    onCalibrate: () => _showCalibrationDialog(context),
                                    onToggleSound: () => context
                                        .read<TrainingBloc>()
                                        .add(ToggleSoundAlerts()),
                                  ),
                                  // Level Display Toggle
                                  LevelDisplayToggle(
                                    onToggle: () => context
                                        .read<TrainingBloc>()
                                        .add(ShowLevelDisplay()),
                                  ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Go Back'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              context.read<TrainingBloc>().add(LoadTrainingData());
                            },
                            child: const Text('Retry'),
                          ),
                        ],
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
      ),
    );
  }

  void _showCalibrationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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

  void _showQuickSessionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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