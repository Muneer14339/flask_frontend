import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/angle_reading.dart';
import '../../domain/entities/position_preset.dart';

class LevelOverlay extends StatefulWidget {
  final AngleReading? currentReading;
  final PositionPreset selectedPosition;
  final VoidCallback onClose;

  const LevelOverlay({
    Key? key,
    this.currentReading,
    required this.selectedPosition,
    required this.onClose,
  }) : super(key: key);

  @override
  State<LevelOverlay> createState() => _LevelOverlayState();
}

class _LevelOverlayState extends State<LevelOverlay> {
  Offset _position = const Offset(0, 0);
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final overlaySize = 250.0;

    // Calculate bubble position based on cant and tilt
    final cant = widget.currentReading?.cant ?? 0.0;
    final tilt = widget.currentReading?.tilt ?? 0.0;

    final scaleFactor = 5.0;
    final bubbleX = (overlaySize / 2) + (cant * scaleFactor);
    final bubbleY = (overlaySize / 2) - (tilt * scaleFactor);

    // Check if angles are within tolerance
    final cantInRange = cant.abs() <= widget.selectedPosition.cantTolerance;
    final tiltInRange = tilt.abs() <= widget.selectedPosition.tiltTolerance;
    final bubbleColor = (cantInRange && tiltInRange) ? AppTheme.success : AppTheme.danger;

    return Positioned(
      left: _position.dx != 0 ? _position.dx : (screenSize.width - overlaySize) / 2,
      top: _position.dy != 0 ? _position.dy : (screenSize.height - overlaySize) / 2,
      child: GestureDetector(
        onPanStart: (details) {
          _isDragging = true;
        },
        onPanUpdate: (details) {
          if (_isDragging) {
            setState(() {
              _position = Offset(
                (_position.dx + details.delta.dx).clamp(0.0, screenSize.width - overlaySize),
                (_position.dy + details.delta.dy).clamp(0.0, screenSize.height - overlaySize),
              );
            });
          }
        },
        onPanEnd: (details) {
          _isDragging = false;
        },
        child: Container(
          width: overlaySize,
          height: overlaySize,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primary, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Cross-hair markers
              Positioned.fill(
                child: CustomPaint(
                  painter: CrosshairPainter(),
                ),
              ),

              // Level bubble
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: bubbleX - 12.5,
                top: bubbleY - 12.5,
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // Close button
              Positioned(
                top: 5,
                right: 5,
                child: GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: AppTheme.danger,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),

              // Stats display
              Positioned(
                bottom: -45,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Cant: ${cant.toStringAsFixed(1)}° | Tilt: ${tilt.toStringAsFixed(1)}°',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // Horizontal line
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );

    // Vertical line
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}