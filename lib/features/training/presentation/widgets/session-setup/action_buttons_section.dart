// lib/features/training/presentation/widgets/session-setup/action_buttons_section.dart
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class ActionButtonsSection extends StatelessWidget {
  final int completedSections; // Dynamic completion count (1-3)
  final Map<String, bool> sectionCompletions; // ✅ NEW: Section-wise completion status
  final VoidCallback onStartSession;
  final VoidCallback onSaveAsTemplate;

  const ActionButtonsSection({
    super.key,
    required this.completedSections,
    required this.sectionCompletions, // ✅ NEW: Required parameter
    required this.onStartSession,
    required this.onSaveAsTemplate,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Required sections: device, loadout, session (3 total)
    const int requiredSections = 3;
    final bool canStart = completedSections >= requiredSections;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ NEW: Section completion status display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: canStart ? AppTheme.success : AppTheme.warning,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      canStart ? Icons.check_circle : Icons.pending_actions,
                      color: canStart ? AppTheme.success : AppTheme.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Setup Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: canStart ? AppTheme.success : AppTheme.warning,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: canStart
                            ? AppTheme.success.withOpacity(0.1)
                            : AppTheme.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$completedSections/$requiredSections',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: canStart ? AppTheme.success : AppTheme.warning,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ✅ Individual section status
                _buildSectionStatus('Device Connection', sectionCompletions['device'] ?? false, 1),
                _buildSectionStatus('Loadout Configuration', sectionCompletions['loadout'] ?? false, 2),
                _buildSectionStatus('Session Information', sectionCompletions['session'] ?? false, 3),

                if (!canStart) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppTheme.info, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getNextStepMessage(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.info,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              // Save as Template Button
              Expanded(
                child: ElevatedButton(
                  onPressed: onSaveAsTemplate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.surface,
                    foregroundColor: AppTheme.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: AppTheme.borderColor),
                    ),
                    elevation: 2,
                    minimumSize: const Size.fromHeight(50), // ✅ fixes height
                  ),
                  child: const Text(
                    textAlign: TextAlign.center,
                    'Save as Template',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Start Session Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: canStart ? onStartSession : null,
                  icon: Icon(
                    canStart ? Icons.play_arrow : Icons.lock,
                    size: 20,
                  ),
                  label: Text(
                    textAlign: TextAlign.center,
                    canStart ? 'Start Training' : 'Complete Setup',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: canStart ? Colors.white : AppTheme.textSecondary,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canStart ? AppTheme.success : AppTheme.borderColor,
                    foregroundColor: canStart ? Colors.white : AppTheme.textSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: canStart ? 3 : 0,
                    minimumSize: const Size.fromHeight(50), // ✅ fixes height
                  ),
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }

  // ✅ NEW: Build individual section status row
  Widget _buildSectionStatus(String sectionName, bool isCompleted, int sectionNumber) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? AppTheme.success : AppTheme.borderColor,
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 12)
                : Text(
              '$sectionNumber',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              sectionName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isCompleted ? AppTheme.success : AppTheme.textPrimary,
              ),
            ),
          ),
          if (isCompleted)
            const Icon(Icons.check_circle_outline, color: AppTheme.success, size: 16),
        ],
      ),
    );
  }

  // ✅ NEW: Get next step message based on current completion status
  String _getNextStepMessage() {
    if (!(sectionCompletions['device'] ?? false)) {
      return 'Connect your RifleAxis device to continue';
    } else if (!(sectionCompletions['loadout'] ?? false)) {
      return 'Configure your loadout with a rifle that has ammunition';
    } else if (!(sectionCompletions['session'] ?? false)) {
      return 'Complete session information (name, type, position, distance)';
    } else {
      return 'All required sections completed!';
    }
  }
}