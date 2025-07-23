// lib/features/training/presentation/widgets/session_planning_section.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SessionPlanningSection extends StatefulWidget {
  const SessionPlanningSection({Key? key}) : super(key: key);

  @override
  State<SessionPlanningSection> createState() => _SessionPlanningSectionState();
}

class _SessionPlanningSectionState extends State<SessionPlanningSection> {
  final _sessionNotesController = TextEditingController();

  // ✅ NEW: Check if section is completed (optional section, so always true)
  bool get isCompleted => true; // Session planning is optional

  @override
  Widget build(BuildContext context) {
    return _buildSection(
      title: '📝 Session Planning',
      sectionNumber: 5,
      isCompleted: isCompleted,
      isOptional: true, // ✅ NEW: Mark as optional
      child: _buildFormField(
        'Session Goals/Notes',
        _sessionNotesController,
        'What are you working on today? Any specific goals or observations...',
        maxLines: 4,
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required int sectionNumber,
    required bool isCompleted,
    required Widget child,
    bool isOptional = false, // ✅ NEW: Optional parameter
  }) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                        title,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600
                        )
                    ),
                    if (isOptional) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.textSecondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Optional',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? AppTheme.success : AppTheme.borderColor,
                ),
                child: isCompleted
                    ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16
                )
                    : Text(
                  '$sectionNumber',
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildFormField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _sessionNotesController.dispose();
    super.dispose();
  }
}