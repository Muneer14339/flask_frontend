import 'package:equatable/equatable.dart';

import 'angle_reading.dart';
import 'session_stats.dart';

class TrainingSession extends Equatable {
  final String id;
  final String name;
  final String type;
  final String? notes;
  final String? weather;
  final double? windSpeed;
  final double? temperature;
  final double? humidity;
  final DateTime startTime;
  final DateTime? endTime;
  final List<AngleReading> readings;
  final SessionStats stats;

  const TrainingSession({
    required this.id,
    required this.name,
    required this.type,
    this.notes,
    this.weather,
    this.windSpeed,
    this.temperature,
    this.humidity,
    required this.startTime,
    this.endTime,
    required this.readings,
    required this.stats,
  });

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  bool get isActive => endTime == null;

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    notes,
    weather,
    windSpeed,
    temperature,
    humidity,
    startTime,
    endTime,
    readings,
    stats,
  ];
}