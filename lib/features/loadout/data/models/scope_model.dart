// lib/features/Loadout/data/models/scope_model.dart
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/scope.dart';

// part 'scope_model.g.dart';

@HiveType(typeId: 7)
class ScopeModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String manufacturer;

  @HiveField(2)
  String model;

  @HiveField(3)
  String? tubeSize;

  @HiveField(4)
  String? focalPlane;

  @HiveField(5)
  String? reticle;

  @HiveField(6)
  String? trackingUnits;

  @HiveField(7)
  String? clickValue;

  @HiveField(8)
  TotalTravelModel totalTravel;

  @HiveField(9)
  List<ZeroDataModel> zeroData;

  @HiveField(10)
  String? notes;

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

  // NEW: Firestore serialization methods
  factory ScopeModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ScopeModel(
      id: id,
      manufacturer: data['manufacturer'] ?? '',
      model: data['model'] ?? '',
      tubeSize: data['tubeSize'],
      focalPlane: data['focalPlane'],
      reticle: data['reticle'],
      trackingUnits: data['trackingUnits'],
      clickValue: data['clickValue'],
      totalTravel: TotalTravelModel.fromFirestore(data['totalTravel'] ?? {}),
      zeroData: (data['zeroData'] as List?)
          ?.map((item) => ZeroDataModel.fromFirestore(item))
          .toList() ?? [],
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'manufacturer': manufacturer,
      'model': model,
      'tubeSize': tubeSize,
      'focalPlane': focalPlane,
      'reticle': reticle,
      'trackingUnits': trackingUnits,
      'clickValue': clickValue,
      'totalTravel': totalTravel.toFirestore(),
      'zeroData': zeroData.map((zero) => zero.toFirestore()).toList(),
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
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

@HiveType(typeId: 8)
class TotalTravelModel extends HiveObject {
  @HiveField(0)
  String? elevation;

  @HiveField(1)
  String? windage;

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

  // NEW: Firestore methods
  factory TotalTravelModel.fromFirestore(Map<String, dynamic> data) {
    return TotalTravelModel(
      elevation: data['elevation'],
      windage: data['windage'],
    );
  }

  Map<String, dynamic> toFirestore() {
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

@HiveType(typeId: 9)
class ZeroDataModel extends HiveObject {
  @HiveField(0)
  int distance;

  @HiveField(1)
  String units;

  @HiveField(2)
  String elevation;

  @HiveField(3)
  String windage;

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

  // NEW: Firestore methods
  factory ZeroDataModel.fromFirestore(Map<String, dynamic> data) {
    return ZeroDataModel(
      distance: data['distance'] ?? 0,
      units: data['units'] ?? 'yards',
      elevation: data['elevation'] ?? '0',
      windage: data['windage'] ?? '0',
    );
  }

  Map<String, dynamic> toFirestore() {
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