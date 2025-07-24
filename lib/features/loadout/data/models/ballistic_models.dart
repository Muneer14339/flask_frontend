// lib/features/loadout/data/models/ballistic_models.dart
import '../../domain/entities/ballistic_data.dart';

class DopeEntryModel {
  final String id;
  final String rifleId;
  final String ammunitionId;
  final int distance;
  final String elevation;
  final String windage;
  final DateTime createdAt;
  final String? notes;

  DopeEntryModel({
    required this.id,
    required this.rifleId,
    required this.ammunitionId,
    required this.distance,
    required this.elevation,
    required this.windage,
    required this.createdAt,
    this.notes,
  });

  factory DopeEntryModel.fromEntity(DopeEntry entity) {
    return DopeEntryModel(
      id: entity.id,
      rifleId: entity.rifleId,
      ammunitionId: entity.ammunitionId,
      distance: entity.distance,
      elevation: entity.elevation,
      windage: entity.windage,
      createdAt: entity.createdAt,
      notes: entity.notes,
    );
  }

  factory DopeEntryModel.fromJson(Map<String, dynamic> json) {
    return DopeEntryModel(
      id: json['id'] ?? '',
      rifleId: json['rifleId'] ?? '',
      ammunitionId: json['ammunitionId'] ?? '',
      distance: json['distance'] ?? 0,
      elevation: json['elevation'] ?? '0',
      windage: json['windage'] ?? '0',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rifleId': rifleId,
      'ammunitionId': ammunitionId,
      'distance': distance,
      'elevation': elevation,
      'windage': windage,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
    };
  }

  DopeEntry toEntity() {
    return DopeEntry(
      id: id,
      rifleId: rifleId,
      ammunitionId: ammunitionId,
      distance: distance,
      elevation: elevation,
      windage: windage,
      createdAt: createdAt,
      notes: notes,
    );
  }
}

class ZeroEntryModel {
  final String id;
  final String rifleId;
  final int distance;
  final String poiOffset;
  final bool confirmed;
  final DateTime createdAt;
  final String? notes;

  ZeroEntryModel({
    required this.id,
    required this.rifleId,
    required this.distance,
    required this.poiOffset,
    required this.confirmed,
    required this.createdAt,
    this.notes,
  });

  factory ZeroEntryModel.fromEntity(ZeroEntry entity) {
    return ZeroEntryModel(
      id: entity.id,
      rifleId: entity.rifleId,
      distance: entity.distance,
      poiOffset: entity.poiOffset,
      confirmed: entity.confirmed,
      createdAt: entity.createdAt,
      notes: entity.notes,
    );
  }

  factory ZeroEntryModel.fromJson(Map<String, dynamic> json) {
    return ZeroEntryModel(
      id: json['id'] ?? '',
      rifleId: json['rifleId'] ?? '',
      distance: json['distance'] ?? 0,
      poiOffset: json['poiOffset'] ?? '0',
      confirmed: json['confirmed'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rifleId': rifleId,
      'distance': distance,
      'poiOffset': poiOffset,
      'confirmed': confirmed,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
    };
  }

  ZeroEntry toEntity() {
    return ZeroEntry(
      id: id,
      rifleId: rifleId,
      distance: distance,
      poiOffset: poiOffset,
      confirmed: confirmed,
      createdAt: createdAt,
      notes: notes,
    );
  }
}

class ChronographDataModel {
  final String id;
  final String rifleId;
  final String ammunitionId;
  final List<double> velocities;
  final double average;
  final double extremeSpread;
  final double standardDeviation;
  final DateTime createdAt;
  final String? notes;

  ChronographDataModel({
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

  factory ChronographDataModel.fromEntity(ChronographData entity) {
    return ChronographDataModel(
      id: entity.id,
      rifleId: entity.rifleId,
      ammunitionId: entity.ammunitionId,
      velocities: entity.velocities,
      average: entity.average,
      extremeSpread: entity.extremeSpread,
      standardDeviation: entity.standardDeviation,
      createdAt: entity.createdAt,
      notes: entity.notes,
    );
  }

  factory ChronographDataModel.fromJson(Map<String, dynamic> json) {
    return ChronographDataModel(
      id: json['id'] ?? '',
      rifleId: json['rifleId'] ?? '',
      ammunitionId: json['ammunitionId'] ?? '',
      velocities: List<double>.from(json['velocities'] ?? []),
      average: (json['average'] ?? 0.0).toDouble(),
      extremeSpread: (json['extremeSpread'] ?? 0.0).toDouble(),
      standardDeviation: (json['standardDeviation'] ?? 0.0).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rifleId': rifleId,
      'ammunitionId': ammunitionId,
      'velocities': velocities,
      'average': average,
      'extremeSpread': extremeSpread,
      'standardDeviation': standardDeviation,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
    };
  }

  ChronographData toEntity() {
    return ChronographData(
      id: id,
      rifleId: rifleId,
      ammunitionId: ammunitionId,
      velocities: velocities,
      average: average,
      extremeSpread: extremeSpread,
      standardDeviation: standardDeviation,
      createdAt: createdAt,
      notes: notes,
    );
  }
}

class BallisticCalculationModel {
  final String id;
  final String rifleId;
  final String ammunitionId;
  final double ballisticCoefficient;
  final double muzzleVelocity;
  final int targetDistance;
  final double windSpeed;
  final double windDirection;
  final List<BallisticPointModel> trajectoryData;
  final DateTime createdAt;
  final String? notes;

  BallisticCalculationModel({
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

  factory BallisticCalculationModel.fromEntity(BallisticCalculation entity) {
    return BallisticCalculationModel(
      id: entity.id,
      rifleId: entity.rifleId,
      ammunitionId: entity.ammunitionId,
      ballisticCoefficient: entity.ballisticCoefficient,
      muzzleVelocity: entity.muzzleVelocity,
      targetDistance: entity.targetDistance,
      windSpeed: entity.windSpeed,
      windDirection: entity.windDirection,
      trajectoryData: entity.trajectoryData.map((e) => BallisticPointModel.fromEntity(e)).toList(),
      createdAt: entity.createdAt,
      notes: entity.notes,
    );
  }

  factory BallisticCalculationModel.fromJson(Map<String, dynamic> json) {
    return BallisticCalculationModel(
      id: json['id'] ?? '',
      rifleId: json['rifleId'] ?? '',
      ammunitionId: json['ammunitionId'] ?? '',
      ballisticCoefficient: (json['ballisticCoefficient'] ?? 0.0).toDouble(),
      muzzleVelocity: (json['muzzleVelocity'] ?? 0.0).toDouble(),
      targetDistance: json['targetDistance'] ?? 0,
      windSpeed: (json['windSpeed'] ?? 0.0).toDouble(),
      windDirection: (json['windDirection'] ?? 0.0).toDouble(),
      trajectoryData: (json['trajectoryData'] as List?)
          ?.map((e) => BallisticPointModel.fromJson(e))
          .toList() ?? [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rifleId': rifleId,
      'ammunitionId': ammunitionId,
      'ballisticCoefficient': ballisticCoefficient,
      'muzzleVelocity': muzzleVelocity,
      'targetDistance': targetDistance,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'trajectoryData': trajectoryData.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
    };
  }

  BallisticCalculation toEntity() {
    return BallisticCalculation(
      id: id,
      rifleId: rifleId,
      ammunitionId: ammunitionId,
      ballisticCoefficient: ballisticCoefficient,
      muzzleVelocity: muzzleVelocity,
      targetDistance: targetDistance,
      windSpeed: windSpeed,
      windDirection: windDirection,
      trajectoryData: trajectoryData.map((e) => e.toEntity()).toList(),
      createdAt: createdAt,
      notes: notes,
    );
  }
}

class BallisticPointModel {
  final int range;
  final double drop;
  final double windDrift;
  final double velocity;
  final double energy;
  final double timeOfFlight;

  BallisticPointModel({
    required this.range,
    required this.drop,
    required this.windDrift,
    required this.velocity,
    required this.energy,
    required this.timeOfFlight,
  });

  factory BallisticPointModel.fromEntity(BallisticPoint entity) {
    return BallisticPointModel(
      range: entity.range,
      drop: entity.drop,
      windDrift: entity.windDrift,
      velocity: entity.velocity,
      energy: entity.energy,
      timeOfFlight: entity.timeOfFlight,
    );
  }

  factory BallisticPointModel.fromJson(Map<String, dynamic> json) {
    return BallisticPointModel(
      range: json['range'] ?? 0,
      drop: (json['drop'] ?? 0.0).toDouble(),
      windDrift: (json['windDrift'] ?? 0.0).toDouble(),
      velocity: (json['velocity'] ?? 0.0).toDouble(),
      energy: (json['energy'] ?? 0.0).toDouble(),
      timeOfFlight: (json['timeOfFlight'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'range': range,
      'drop': drop,
      'windDrift': windDrift,
      'velocity': velocity,
      'energy': energy,
      'timeOfFlight': timeOfFlight,
    };
  }

  BallisticPoint toEntity() {
    return BallisticPoint(
      range: range,
      drop: drop,
      windDrift: windDrift,
      velocity: velocity,
      energy: energy,
      timeOfFlight: timeOfFlight,
    );
  }
}