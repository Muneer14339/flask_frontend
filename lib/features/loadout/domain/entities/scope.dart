import 'package:equatable/equatable.dart';

class Scope extends Equatable {
  final String id;
  final String manufacturer;
  final String model;
  final String? tubeSize;
  final String? focalPlane;
  final String? reticle;
  final String? trackingUnits;
  final String? clickValue;
  final TotalTravel totalTravel;
  final List<ZeroData> zeroData;
  final String? notes;

  const Scope({
    required this.id,
    required this.manufacturer,
    required this.model,
    this.tubeSize,
    this.focalPlane,
    this.reticle,
    this.trackingUnits,
    this.clickValue,
    required this.totalTravel,
    required this.zeroData,
    this.notes,
  });

  @override
  List<Object?> get props => [
    id,
    manufacturer,
    model,
    tubeSize,
    focalPlane,
    reticle,
    trackingUnits,
    clickValue,
    totalTravel,
    zeroData,
    notes,
  ];
}

class TotalTravel extends Equatable {
  final String? elevation;
  final String? windage;

  const TotalTravel({
    this.elevation,
    this.windage,
  });

  @override
  List<Object?> get props => [elevation, windage];
}

class ZeroData extends Equatable {
  final int distance;
  final String units;
  final String elevation;
  final String windage;

  const ZeroData({
    required this.distance,
    required this.units,
    required this.elevation,
    required this.windage,
  });

  @override
  List<Object?> get props => [distance, units, elevation, windage];
}