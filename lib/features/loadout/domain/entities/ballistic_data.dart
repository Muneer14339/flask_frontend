// lib/features/loadout/domain/entities/ballistic_data.dart
import 'package:equatable/equatable.dart';

class DopeEntry extends Equatable {
  final String id;
  final String rifleId;
  final String ammunitionId;
  final int distance;
  final String elevation;
  final String windage;
  final DateTime createdAt;
  final String? notes;

  const DopeEntry({
    required this.id,
    required this.rifleId,
    required this.ammunitionId,
    required this.distance,
    required this.elevation,
    required this.windage,
    required this.createdAt,
    this.notes,
  });

  @override
  List<Object?> get props => [
    id,
    rifleId,
    ammunitionId,
    distance,
    elevation,
    windage,
    createdAt,
    notes,
  ];
}

class ZeroEntry extends Equatable {
  final String id;
  final String rifleId;
  final int distance;
  final String poiOffset;
  final bool confirmed;
  final DateTime createdAt;
  final String? notes;

  const ZeroEntry({
    required this.id,
    required this.rifleId,
    required this.distance,
    required this.poiOffset,
    required this.confirmed,
    required this.createdAt,
    this.notes,
  });

  @override
  List<Object?> get props => [
    id,
    rifleId,
    distance,
    poiOffset,
    confirmed,
    createdAt,
    notes,
  ];
}

class ChronographData extends Equatable {
  final String id;
  final String rifleId;
  final String ammunitionId;
  final List<double> velocities;
  final double average;
  final double extremeSpread;
  final double standardDeviation;
  final DateTime createdAt;
  final String? notes;

  const ChronographData({
    required this.id,
    required this.rifleId,
    required this.ammunitionId,
    required this.velocities,
    required this.average,
    required this.extremeSpread,
    required this.standardDeviation,
    required this.createdAt,
    this.notes,
  });

  @override
  List<Object?> get props => [
    id,
    rifleId,
    ammunitionId,
    velocities,
    average,
    extremeSpread,
    standardDeviation,
    createdAt,
    notes,
  ];
}

class BallisticCalculation extends Equatable {
  final String id;
  final String rifleId;
  final String ammunitionId;
  final double ballisticCoefficient;
  final double muzzleVelocity;
  final int targetDistance;
  final double windSpeed;
  final double windDirection;
  final List<BallisticPoint> trajectoryData;
  final DateTime createdAt;
  final String? notes;

  const BallisticCalculation({
    required this.id,
    required this.rifleId,
    required this.ammunitionId,
    required this.ballisticCoefficient,
    required this.muzzleVelocity,
    required this.targetDistance,
    required this.windSpeed,
    required this.windDirection,
    required this.trajectoryData,
    required this.createdAt,
    this.notes,
  });

  @override
  List<Object?> get props => [
    id,
    rifleId,
    ammunitionId,
    ballisticCoefficient,
    muzzleVelocity,
    targetDistance,
    windSpeed,
    windDirection,
    trajectoryData,
    createdAt,
    notes,
  ];
}

class BallisticPoint extends Equatable {
  final int range;
  final double drop;
  final double windDrift;
  final double velocity;
  final double energy;
  final double timeOfFlight;

  const BallisticPoint({
    required this.range,
    required this.drop,
    required this.windDrift,
    required this.velocity,
    required this.energy,
    required this.timeOfFlight,
  });

  @override
  List<Object> get props => [
    range,
    drop,
    windDrift,
    velocity,
    energy,
    timeOfFlight,
  ];
}