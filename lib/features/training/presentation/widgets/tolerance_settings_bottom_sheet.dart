import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wheel_slider/wheel_slider.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/training_bloc.dart';
import '../bloc/training_event.dart';

class CustomToleranceBottomSheet extends StatefulWidget {
  final double currentCantTolerance;
  final double currentTiltTolerance;

  const CustomToleranceBottomSheet({
    Key? key,
    required this.currentCantTolerance,
    required this.currentTiltTolerance,
  }) : super(key: key);

  @override
  State<CustomToleranceBottomSheet> createState() => _CustomToleranceBottomSheetState();
}

class _CustomToleranceBottomSheetState extends State<CustomToleranceBottomSheet> {
  late double _cantTolerance;
  late double _tiltTolerance;

  @override
  void initState() {
    super.initState();
    _cantTolerance = widget.currentCantTolerance;
    _tiltTolerance = widget.currentTiltTolerance;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7, // ⬅️ Shorter height
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Custom Tolerances',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildToleranceSection(
                      title: 'Cant Tolerance',
                      subtitle: 'Left/Right rifle tilt tolerance',
                      currentValue: _cantTolerance,
                      onChanged: (val) => setState(() => _cantTolerance = val),
                      color: AppTheme.primary,
                      icon: Icons.rotate_90_degrees_ccw,
                    ),
                    const SizedBox(height: 12),
                    _buildToleranceSection(
                      title: 'Tilt Tolerance',
                      subtitle: 'Up/Down rifle angle tolerance',
                      currentValue: _tiltTolerance,
                      onChanged: (val) => setState(() => _tiltTolerance = val),
                      color: AppTheme.primary,
                      icon: Icons.rotate_right,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              context.read<TrainingBloc>().add(ResetCustomTolerances());
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: AppTheme.textSecondary),
                            ),
                            child: const Text(
                              'Reset',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<TrainingBloc>().add(
                                UpdateCustomCantTolerance(cantTolerance: _cantTolerance),
                              );
                              context.read<TrainingBloc>().add(
                                UpdateCustomTiltTolerance(tiltTolerance: _tiltTolerance),
                              );
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Apply Settings',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToleranceSection({
    required String title,
    required String subtitle,
    required double currentValue,
    required Function(double) onChanged,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              '±${currentValue.toStringAsFixed(1)}°',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: WheelSlider.number(
            totalCount: 100,
            initValue: (currentValue * 10).round(),
            currentIndex: (currentValue * 10).round(),
            onValueChanged: (val) => onChanged((val / 10.0).clamp(0.1, 10.0)),
            itemSize: 36,
            hapticFeedbackType: HapticFeedbackType.lightImpact,
            showPointer: true,
            pointerColor: color,
            squeeze: 1.1,
            perspective: 0.01,
            customPointer: Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0.1°', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            Text('10.0°', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
      ],
    );
  }



}
