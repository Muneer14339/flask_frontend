import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/position_preset.dart';
import 'tolerance_settings_bottom_sheet.dart';

class PositionSelector extends StatelessWidget {
  final PositionPreset selectedPosition;
  final Function(PositionPreset) onPositionChanged;
  final double customCantTolerance;
  final double customTiltTolerance;

  const PositionSelector({
    Key? key,
    required this.selectedPosition,
    required this.onPositionChanged,
    required this.customCantTolerance,
    required this.customTiltTolerance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Header with settings icon for custom position
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Shooting Position',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primary,
                ),
              ),
              // ✅ Show settings icon only for custom position
              if (selectedPosition.id == 'custom')
                GestureDetector(
                  onTap: () => _showCustomToleranceSettings(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.settings,
                      color: AppTheme.primary,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Dropdown with dynamic description for custom position
          DropdownButtonFormField<PositionPreset>(
            value: selectedPosition,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: AppTheme.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: AppTheme.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: AppTheme.primary),
              ),
              contentPadding: const EdgeInsets.all(12),
              fillColor: AppTheme.surface,
              filled: true,
            ),
            items: PositionPreset.presets.map((preset) {
              return DropdownMenuItem<PositionPreset>(
                value: preset,
                child: Text(_getDisplayText(preset)),
              );
            }).toList(),
            onChanged: (preset) {
              if (preset != null) {
                onPositionChanged(preset);
              }
            },
            isExpanded: true,
          ),
        ],
      ),
    );
  }

  // ✅ Get display text with custom values for custom position
  String _getDisplayText(PositionPreset preset) {
    if (preset.id == 'custom') {
      return '${preset.name} (±${customCantTolerance.toStringAsFixed(1)}° cant, ±${customTiltTolerance.toStringAsFixed(1)}° tilt)';
    }
    return '${preset.name} (${preset.description})';
  }

  // ✅ Show custom tolerance settings bottom sheet
  void _showCustomToleranceSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomToleranceBottomSheet(
        currentCantTolerance: customCantTolerance,
        currentTiltTolerance: customTiltTolerance,
      ),
    );
  }
}