import 'package:equatable/equatable.dart';

class CSVScopeEntity extends Equatable {
  final String manufacturer;
  final String model;
  final String tubeSize;
  final String focalPlane;
  final String reticle;
  final String trackingUnits;
  final String clickValue;
  final String maxElevation;
  final String maxWindage;

  const CSVScopeEntity({
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
}