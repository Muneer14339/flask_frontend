// lib/features/Loadout/data/models/maintenance_model.dart
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/maintenance.dart';

// part 'maintenance_model.g.dart';

@HiveType(typeId: 10)
class MaintenanceModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String rifleId;

  @HiveField(3)
  String type;

  @HiveField(4)
  MaintenanceIntervalModel interval;

  @HiveField(5)
  DateTime? lastCompleted;

  @HiveField(6)
  int? currentCount;

  @HiveField(7)
  String? torqueSpec;

  @HiveField(8)
  String? notes;

  @HiveField(9) // NEW: Add HiveField for createdAt
  DateTime? createdAt;

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
    this.createdAt, // NEW
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
      createdAt: maintenance.createdAt, // NEW
    );
  }


  factory MaintenanceModel.fromFirestore(Map<String, dynamic> data, String id) {
    return MaintenanceModel(
      id: id,
      title: data['title'] ?? '',
      rifleId: data['rifleId'] ?? '',
      type: data['type'] ?? '',
      interval: MaintenanceIntervalModel.fromFirestore(data['interval'] ?? {}),
      lastCompleted: data['lastCompleted'] != null
          ? (data['lastCompleted'] as Timestamp).toDate()
          : null,
      currentCount: data['currentCount'],
      torqueSpec: data['torqueSpec'],
      notes: data['notes'],
      createdAt: data['createdAt'] != null // NEW: Handle createdAt
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'rifleId': rifleId,
      'type': type,
      'interval': interval.toFirestore(),
      'lastCompleted': lastCompleted != null ? Timestamp.fromDate(lastCompleted!) : null,
      'currentCount': currentCount,
      'torqueSpec': torqueSpec,
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(), // Already included
      'updatedAt': FieldValue.serverTimestamp(),
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
      createdAt: createdAt, // NEW
    );
  }
}

@HiveType(typeId: 11)
class MaintenanceIntervalModel extends HiveObject {
  @HiveField(0)
  int value;

  @HiveField(1)
  String unit;

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

  // NEW: Firestore methods
  factory MaintenanceIntervalModel.fromFirestore(Map<String, dynamic> data) {
    return MaintenanceIntervalModel(
      value: data['value'] ?? 0,
      unit: data['unit'] ?? 'days',
    );
  }

  Map<String, dynamic> toFirestore() {
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