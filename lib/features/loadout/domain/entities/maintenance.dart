import 'package:equatable/equatable.dart';

class Maintenance extends Equatable {
  final String id;
  final String title;
  final String rifleId;
  final String type;
  final MaintenanceInterval interval;
  final DateTime? lastCompleted;
  final int? currentCount;
  final String? torqueSpec;
  final String? notes;
  final DateTime? createdAt; // NEW: Add createdAt field

  const Maintenance({
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

  Maintenance copyWith({
    String? id,
    String? title,
    String? rifleId,
    String? type,
    MaintenanceInterval? interval,
    DateTime? lastCompleted,
    int? currentCount,
    String? torqueSpec,
    String? notes,
    DateTime? createdAt, // NEW
  }) {
    return Maintenance(
      id: id ?? this.id,
      title: title ?? this.title,
      rifleId: rifleId ?? this.rifleId,
      type: type ?? this.type,
      interval: interval ?? this.interval,
      lastCompleted: lastCompleted ?? this.lastCompleted,
      currentCount: currentCount ?? this.currentCount,
      torqueSpec: torqueSpec ?? this.torqueSpec,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt, // NEW
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        rifleId,
        type,
        interval,
        lastCompleted,
        currentCount,
        torqueSpec,
        notes,
        createdAt, // NEW
      ];
}

class MaintenanceInterval extends Equatable {
  final int value;
  final String unit;

  const MaintenanceInterval({
    required this.value,
    required this.unit,
  });

  @override
  List<Object> get props => [value, unit];
}
