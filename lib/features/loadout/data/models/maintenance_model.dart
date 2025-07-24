// lib/features/loadout/data/models/maintenance_model.dart
import '../../domain/entities/maintenance.dart';

class MaintenanceModel {
  final String id;
  final String title;
  final String rifleId;
  final String type;
  final MaintenanceIntervalModel interval;
  final DateTime? lastCompleted;
  final int? currentCount;
  final String? torqueSpec;
  final String? notes;
  final DateTime? createdAt;

  MaintenanceModel({
    required this.id,
    required this.title,
    required this.rifleId,
    required this.type,
    required this.interval,
    this.lastCompleted,
    this.currentCount,
    this.torqueSpec,
    this.notes,
    this.createdAt,
  });

  factory MaintenanceModel.fromEntity(Maintenance maintenance) {
    return MaintenanceModel(
      id: maintenance.id,
      title: maintenance.title,
      rifleId: maintenance.rifleId,
      type: maintenance.type,
      interval: MaintenanceIntervalModel.fromEntity(maintenance.interval),
      lastCompleted: maintenance.lastCompleted,
      currentCount: maintenance.currentCount,
      torqueSpec: maintenance.torqueSpec,
      notes: maintenance.notes,
      createdAt: maintenance.createdAt,
    );
  }

  factory MaintenanceModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      rifleId: json['rifleId'] ?? '',
      type: json['type'] ?? '',
      interval: MaintenanceIntervalModel.fromJson(json['interval'] ?? {}),
      lastCompleted: json['lastCompleted'] != null
          ? DateTime.parse(json['lastCompleted'])
          : null,
      currentCount: json['currentCount'],
      torqueSpec: json['torqueSpec'],
      notes: json['notes'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'rifleId': rifleId,
      'type': type,
      'interval': interval.toJson(),
      'lastCompleted': lastCompleted?.toIso8601String(),
      'currentCount': currentCount,
      'torqueSpec': torqueSpec,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Maintenance toEntity() {
    return Maintenance(
      id: id,
      title: title,
      rifleId: rifleId,
      type: type,
      interval: interval.toEntity(),
      lastCompleted: lastCompleted,
      currentCount: currentCount,
      torqueSpec: torqueSpec,
      notes: notes,
      createdAt: createdAt,
    );
  }
}

class MaintenanceIntervalModel {
  final int value;
  final String unit;

  MaintenanceIntervalModel({
    required this.value,
    required this.unit,
  });

  factory MaintenanceIntervalModel.fromEntity(MaintenanceInterval interval) {
    return MaintenanceIntervalModel(
      value: interval.value,
      unit: interval.unit,
    );
  }

  factory MaintenanceIntervalModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceIntervalModel(
      value: json['value'] ?? 0,
      unit: json['unit'] ?? 'days',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'unit': unit,
    };
  }

  MaintenanceInterval toEntity() {
    return MaintenanceInterval(
      value: value,
      unit: unit,
    );
  }
}