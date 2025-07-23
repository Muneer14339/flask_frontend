import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedLoadingOverlay extends StatefulWidget {
  final String message;
  final bool isVisible;

  const AnimatedLoadingOverlay({
    Key? key,
    required this.message,
    required this.isVisible,
  }) : super(key: key);

  @override
  State<AnimatedLoadingOverlay> createState() => _AnimatedLoadingOverlayState();
}

class _AnimatedLoadingOverlayState extends State<AnimatedLoadingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    if (widget.isVisible) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedLoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _controller.repeat();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Smooth Bubbles Animation
            SizedBox(
              width: 140,
              height: 40,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      final animationValue = (_controller.value + index * 0.2) % 1.0;
                      final scale = 0.7 + 0.3 * sin(animationValue * 2 * pi);
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 12 * scale,
                        height: 12 * scale,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // ✅ Gradient 3D text with animated dots
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                int dotCount = (_controller.value * 4).floor() % 4;
                String dots = '.' * dotCount;
                return ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      colors: [Colors.blueAccent, Colors.cyanAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: Text(
                    '${widget.message}$dots',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white, // fallback
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      height: 1.3,
                      shadows: [
                        Shadow(
                          blurRadius: 6,
                          color: Colors.black54,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}