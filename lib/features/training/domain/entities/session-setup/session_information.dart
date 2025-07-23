// lib/features/training/domain/entities/session_information.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SessionInformation extends Equatable {
  final String? sessionName;
  final String? sessionType;
  final DateTime? date;
  final TimeOfDay? time;
  final String? shootingPosition;
  final String? distance;

  const SessionInformation({
    this.sessionName,
    this.sessionType,
    this.date,
    this.time,
    this.shootingPosition,
    this.distance,
  });

  // Check if all required fields are completed
  bool get isComplete {
    return sessionName != null && sessionName!.trim().isNotEmpty &&
        sessionType != null && sessionType!.trim().isNotEmpty &&
        shootingPosition != null && shootingPosition!.trim().isNotEmpty &&
        distance != null && distance!.trim().isNotEmpty;
  }

  SessionInformation copyWith({
    String? sessionName,
    String? sessionType,
    DateTime? date,
    TimeOfDay? time,
    String? shootingPosition,
    String? distance,
    bool clearSessionName = false,
    bool clearSessionType = false,
    bool clearDate = false,
    bool clearTime = false,
    bool clearShootingPosition = false,
    bool clearDistance = false,
  }) {
    return SessionInformation(
      sessionName: clearSessionName ? null : (sessionName ?? this.sessionName),
      sessionType: clearSessionType ? null : (sessionType ?? this.sessionType),
      date: clearDate ? null : (date ?? this.date),
      time: clearTime ? null : (time ?? this.time),
      shootingPosition: clearShootingPosition ? null : (shootingPosition ?? this.shootingPosition),
      distance: clearDistance ? null : (distance ?? this.distance),
    );
  }

  @override
  List<Object?> get props => [
    sessionName,
    sessionType,
    date,
    time,
    shootingPosition,
    distance,
  ];
}