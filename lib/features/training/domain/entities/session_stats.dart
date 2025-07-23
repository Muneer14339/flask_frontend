import 'package:equatable/equatable.dart';

class SessionStats extends Equatable {
  final double averageCant;
  final double averageTilt;
  final double stabilityPercentage;
  final int goodHolds;
  final int totalReadings;

  const SessionStats({
    required this.averageCant,
    required this.averageTilt,
    required this.stabilityPercentage,
    required this.goodHolds,
    required this.totalReadings,
  });

  @override
  List<Object?> get props => [
    averageCant,
    averageTilt,
    stabilityPercentage,
    goodHolds,
    totalReadings,
  ];
}