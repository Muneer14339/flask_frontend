import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/training_session.dart';
import '../../domain/entities/session_stats.dart';

class SessionStatusSection extends StatefulWidget {
  final TrainingSession session;
  final SessionStats? sessionStats;

  const SessionStatusSection({
    Key? key,
    required this.session,
    this.sessionStats,
  }) : super(key: key);

  @override
  State<SessionStatusSection> createState() => _SessionStatusSectionState();
}

class _SessionStatusSectionState extends State<SessionStatusSection> {
  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.success,
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
        children: [
          // Session Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.session.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 1)),
                builder: (context, snapshot) {
                  return Text(
                    _formatDuration(widget.session.duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Courier New',
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Session Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Avg Cant',
                  widget.sessionStats != null
                      ? '±${widget.sessionStats!.averageCant.toStringAsFixed(1)}°'
                      : '±0.0°',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Stability',
                  widget.sessionStats != null
                      ? '${widget.sessionStats!.stabilityPercentage.toStringAsFixed(0)}%'
                      : '0%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Good Holds',
                  widget.sessionStats?.goodHolds.toString() ?? '0',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}