import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/angle_reading.dart';
import '../../domain/entities/position_preset.dart';

class AngleMetricsGrid extends StatelessWidget {
  final AngleReading? currentReading;
  final PositionPreset selectedPosition;

  const AngleMetricsGrid({
    Key? key,
    this.currentReading,
    required this.selectedPosition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricCard(
              'Cant',
              currentReading?.cant ?? 0.0,
              selectedPosition.cantTolerance,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricCard(
              'Tilt',
              currentReading?.tilt ?? 0.0,
              selectedPosition.tiltTolerance,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricCard(
              'Pan',
              currentReading?.pan ?? 0.0,
              selectedPosition.panTolerance,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, double value, double tolerance) {
    final isInRange = value.abs() <= tolerance;
    final valueColor = isInRange ? AppTheme.success : AppTheme.danger;

    return Container(
      width: 140, // ✅ Thori si choti width
      height: 150, // ✅ Pehle 180 thi → ab 150 → thora slim clean look
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12), // ✅ Thora kam padding
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14, // ✅ Font size thora kam
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '-${tolerance.toStringAsFixed(1)}°',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                '+${tolerance.toStringAsFixed(1)}°',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${value >= 0 ? '+' : ''}${value.toStringAsFixed(1)}°',
              style: TextStyle(
                fontSize: 30, // ✅ Pehle 32 thi → ab 30 → proportionate
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
