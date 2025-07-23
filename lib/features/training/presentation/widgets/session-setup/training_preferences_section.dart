import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/session-setup/training_preferences.dart';

class TrainingPreferencesSection extends StatelessWidget {
  final TrainingPreferences preferences;
  final Function(bool) onSoundEnabledChanged;
  final Function(double) onVolumeChanged;
  final Function(String) onAlertToneChanged;
  final Function(String) onTestSound;

  const TrainingPreferencesSection({
    Key? key,
    required this.preferences,
    required this.onSoundEnabledChanged,
    required this.onVolumeChanged,
    required this.onAlertToneChanged,
    required this.onTestSound,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          const Text(
            'Training Preferences',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),

          const SizedBox(height: 20),

          // Audio Alerts Group
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Audio Alerts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 16),

                // Enable Sound Alerts
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => onSoundEnabledChanged(!preferences.soundEnabled),
                      child: Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: preferences.soundEnabled ? AppTheme.primary : AppTheme.borderColor,
                                width: 2,
                              ),
                              color: preferences.soundEnabled ? AppTheme.primary : AppTheme.surface,
                            ),
                            child: preferences.soundEnabled
                                ? const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            )
                                : null,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Enable Sound Alerts',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Alert Volume
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alert Volume',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppTheme.primary,
                              inactiveTrackColor: AppTheme.borderColor,
                              thumbColor: AppTheme.primary,
                              overlayColor: AppTheme.primary.withOpacity(0.1),
                              trackHeight: 4,
                            ),
                            child: Slider(
                              value: preferences.soundVolume,
                              min: 0,
                              max: 100,
                              divisions: 20,
                              onChanged: onVolumeChanged,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 40,
                          child: Text(
                            '${preferences.soundVolume.round()}%',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

              ],
            ),
          ),
        ],
      ),
    );
  }
}