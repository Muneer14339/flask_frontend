// lib/features/training/presentation/widgets/action_controls_section.dart 
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ActionControlsSection extends StatelessWidget {
  final bool isDeviceConnected;
  final bool hasActiveLoadout;
  final bool isMonitoring;
  final bool isSessionActive;
  final bool soundEnabled;
  final bool isCalibrating;
  final VoidCallback onStartMonitoring;
  final VoidCallback onStopMonitoring;
  final VoidCallback onEndSession;
  final VoidCallback onCalibrate;
  final VoidCallback onToggleSound;

  const ActionControlsSection({
    Key? key,
    required this.isDeviceConnected,
    required this.hasActiveLoadout,
    required this.isMonitoring,
    required this.isSessionActive,
    required this.soundEnabled,
    required this.isCalibrating,
    required this.onStartMonitoring,
    required this.onStopMonitoring,
    required this.onEndSession,
    required this.onCalibrate,
    required this.onToggleSound,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTrainingReady = isDeviceConnected && hasActiveLoadout;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Training readiness warning
          if (!isTrainingReady)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.warning, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppTheme.warning, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Training Setup Required',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.warning,
                          ),
                        ),
                        Text(
                          _getSetupMessage(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Session Controls - 4 buttons matching HTML structure
          Column(
            children: [
              // First row - Calibrate and Sound buttons
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      text: isCalibrating ? '🔧 Calibrating...' : '🔧 Calibrate',
                      backgroundColor: isCalibrating ? AppTheme.borderColor : AppTheme.primaryLight,
                      textColor: isCalibrating ? AppTheme.textSecondary : Colors.white,
                      onPressed: !isCalibrating && isDeviceConnected ? onCalibrate : null,
                      isEnabled: !isCalibrating && isDeviceConnected,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      text: soundEnabled ? '🔊 Sound: ON' : '🔊 Sound: OFF',
                      backgroundColor: AppTheme.warning,
                      textColor: Colors.white,
                      onPressed: onToggleSound,
                      isEnabled: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Second row - Pause/Resume button (full width)
              SizedBox(
                width: double.infinity,
                child: _buildActionButton(
                  text: isMonitoring ? '⏸️ Pause Session' : '▶️ Resume Session',
                  backgroundColor: isMonitoring ? AppTheme.primary : AppTheme.success,
                  textColor: Colors.white,
                  onPressed: isTrainingReady
                      ? (isMonitoring ? onStopMonitoring : onStartMonitoring)
                      : null,
                  isEnabled: isTrainingReady,
                ),
              ),
              const SizedBox(height: 12),

              // Third row - End Session button (full width)
              SizedBox(
                width: double.infinity,
                child: _buildActionButton(
                  text: '🛑 End Session',
                  backgroundColor: isSessionActive ? AppTheme.accent : AppTheme.borderColor,
                  textColor: isSessionActive ? Colors.white : AppTheme.textSecondary,
                  onPressed: isSessionActive ? onEndSession : null,
                  isEnabled: isSessionActive,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getSetupMessage() {
    if (!isDeviceConnected && !hasActiveLoadout) {
      return 'Connect device and activate loadout to start training';
    } else if (!isDeviceConnected) {
      return 'Connect your RifleAxis device to continue';
    } else if (!hasActiveLoadout) {
      return 'Activate a loadout in Settings to start monitoring';
    }
    return 'Setup complete';
  }

  Widget _buildActionButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback? onPressed,
    required bool isEnabled,
  }) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.zero,
          elevation: isEnabled ? 2 : 0,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}