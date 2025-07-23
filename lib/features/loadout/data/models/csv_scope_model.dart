// lib/features/Loadout/data/models/csv_scope_model.dart
import 'package:equatable/equatable.dart';

class CSVScopeModel extends Equatable {
  final String manufacturer;
  final String model;
  final String tubeSize;
  final String focalPlane;
  final String reticle;
  final String trackingUnits;
  final String clickValue;
  final String maxElevation;
  final String maxWindage;

  const CSVScopeModel({
    required this.manufacturer,
    required this.model,
    required this.tubeSize,
    required this.focalPlane,
    required this.reticle,
    required this.trackingUnits,
    required this.clickValue,
    required this.maxElevation,
    required this.maxWindage,
  });

  @override
  List<Object> get props => [
    manufacturer,
    model,
    tubeSize,
    focalPlane,
    reticle,
    trackingUnits,
    clickValue,
    maxElevation,
    maxWindage,
  ];

  CSVScopeModel copyWith({
    String? manufacturer,
    String? model,
    String? tubeSize,
    String? focalPlane,
    String? reticle,
    String? trackingUnits,
    String? clickValue,
    String? maxElevation,
    String? maxWindage,
  }) {
    return CSVScopeModel(
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      tubeSize: tubeSize ?? this.tubeSize,
      focalPlane: focalPlane ?? this.focalPlane,
      reticle: reticle ?? this.reticle,
      trackingUnits: trackingUnits ?? this.trackingUnits,
      clickValue: clickValue ?? this.clickValue,
      maxElevation: maxElevation ?? this.maxElevation,
      maxWindage: maxWindage ?? this.maxWindage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'manufacturer': manufacturer,
      'model': model,
      'tubeSize': tubeSize,
      'focalPlane': focalPlane,
      'reticle': reticle,
      'trackingUnits': trackingUnits,
      'clickValue': clickValue,
      'maxElevation': maxElevation,
      'maxWindage': maxWindage,
    };
  }

  factory CSVScopeModel.fromJson(Map<String, dynamic> json) {
    return CSVScopeModel(
      manufacturer: json['manufacturer'] as String,
      model: json['model'] as String,
      tubeSize: json['tubeSize'] as String,
      focalPlane: json['focalPlane'] as String,
      reticle: json['reticle'] as String,
      trackingUnits: json['trackingUnits'] as String,
      clickValue: json['clickValue'] as String,
      maxElevation: json['maxElevation'] as String,
      maxWindage: json['maxWindage'] as String,
    );
  }
}