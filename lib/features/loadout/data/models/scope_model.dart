// lib/features/loadout/data/models/scope_model.dart
import '../../domain/entities/scope.dart';

class ScopeModel {
  final String id;
  final String manufacturer;
  final String model;
  final String? tubeSize;
  final String? focalPlane;
  final String? reticle;
  final String? trackingUnits;
  final String? clickValue;
  final TotalTravelModel totalTravel;
  final List<ZeroDataModel> zeroData;
  final String? notes;

  ScopeModel({
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

  factory ScopeModel.fromEntity(Scope scope) {
    return ScopeModel(
      id: scope.id,
      manufacturer: scope.manufacturer,
      model: scope.model,
      tubeSize: scope.tubeSize,
      focalPlane: scope.focalPlane,
      reticle: scope.reticle,
      trackingUnits: scope.trackingUnits,
      clickValue: scope.clickValue,
      totalTravel: TotalTravelModel.fromEntity(scope.totalTravel),
      zeroData: scope.zeroData.map((zero) => ZeroDataModel.fromEntity(zero)).toList(),
      notes: scope.notes,
    );
  }

  factory ScopeModel.fromJson(Map<String, dynamic> json) {
    return ScopeModel(
      id: json['id'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      model: json['model'] ?? '',
      tubeSize: json['tubeSize'],
      focalPlane: json['focalPlane'],
      reticle: json['reticle'],
      trackingUnits: json['trackingUnits'],
      clickValue: json['clickValue'],
      totalTravel: TotalTravelModel.fromJson(json['totalTravel'] ?? {}),
      zeroData: (json['zeroData'] as List?)
          ?.map((item) => ZeroDataModel.fromJson(item))
          .toList() ?? [],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'manufacturer': manufacturer,
      'model': model,
      'tubeSize': tubeSize,
      'focalPlane': focalPlane,
      'reticle': reticle,
      'trackingUnits': trackingUnits,
      'clickValue': clickValue,
      'totalTravel': totalTravel.toJson(),
      'zeroData': zeroData.map((zero) => zero.toJson()).toList(),
      'notes': notes,
    };
  }

  Scope toEntity() {
    return Scope(
      id: id,
      manufacturer: manufacturer,
      model: model,
      tubeSize: tubeSize,
      focalPlane: focalPlane,
      reticle: reticle,
      trackingUnits: trackingUnits,
      clickValue: clickValue,
      totalTravel: totalTravel.toEntity(),
      zeroData: zeroData.map((zero) => zero.toEntity()).toList(),
      notes: notes,
    );
  }
}

class TotalTravelModel {
  final String? elevation;
  final String? windage;

  TotalTravelModel({
    this.elevation,
    this.windage,
  });

  factory TotalTravelModel.fromEntity(TotalTravel totalTravel) {
    return TotalTravelModel(
      elevation: totalTravel.elevation,
      windage: totalTravel.windage,
    );
  }

  factory TotalTravelModel.fromJson(Map<String, dynamic> json) {
    return TotalTravelModel(
      elevation: json['elevation'],
      windage: json['windage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'elevation': elevation,
      'windage': windage,
    };
  }

  TotalTravel toEntity() {
    return TotalTravel(
      elevation: elevation,
      windage: windage,
    );
  }
}

class ZeroDataModel {
  final int distance;
  final String units;
  final String elevation;
  final String windage;

  ZeroDataModel({
    required this.distance,
    required this.units,
    required this.elevation,
    required this.windage,
  });

  factory ZeroDataModel.fromEntity(ZeroData zeroData) {
    return ZeroDataModel(
      distance: zeroData.distance,
      units: zeroData.units,
      elevation: zeroData.elevation,
      windage: zeroData.windage,
    );
  }

  factory ZeroDataModel.fromJson(Map<String, dynamic> json) {
    return ZeroDataModel(
      distance: json['distance'] ?? 0,
      units: json['units'] ?? 'yards',
      elevation: json['elevation'] ?? '0',
      windage: json['windage'] ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'distance': distance,
      'units': units,
      'elevation': elevation,
      'windage': windage,
    };
  }

  ZeroData toEntity() {
    return ZeroData(
      distance: distance,
      units: units,
      elevation: elevation,
      windage: windage,
    );
  }
}