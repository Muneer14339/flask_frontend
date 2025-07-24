// lib/features/loadout/domain/entities/rifle.dart
import 'package:equatable/equatable.dart';
import 'scope.dart';
import 'ammunition.dart';

class Rifle extends Equatable {
  final String id;
  final String name;
  final String brand;
  final String manufacturer;
  final String generationVariant;
  final String model;
  final String caliber;
  final Barrel barrel;
  final RAAction action;
  final Stock stock;
  final Scope? scope;
  final Ammunition? ammunition;
  final bool isActive;
  final String? notes;

  // Advanced fields
  final String? serialNumber;
  final String? overallLength;
  final String? weight;
  final String? capacity;
  final String? finish;
  final String? sightType;
  final String? sightOptic;
  final String? sightModel;
  final String? sightHeight;
  final String? purchaseDate;
  final String? modifications;

  const Rifle({
    required this.id,
    required this.name,
    required this.brand,
    required this.manufacturer,
    required this.generationVariant,
    required this.model,
    required this.caliber,
    required this.barrel,
    required this.action,
    required this.stock,
    this.scope,
    this.ammunition,
    required this.isActive,
    this.notes,
    this.serialNumber,
    this.overallLength,
    this.weight,
    this.capacity,
    this.finish,
    this.sightType,
    this.sightOptic,
    this.sightModel,
    this.sightHeight,
    this.purchaseDate,
    this.modifications,
  });

  // ✅ FIXED: Proper copyWith method with clear parameters
  Rifle copyWith({
    String? id,
    String? name,
    String? brand,
    String? manufacturer,
    String? generationVariant,
    String? model,
    String? caliber,
    Barrel? barrel,
    RAAction? action,
    Stock? stock,
    Scope? scope,
    Ammunition? ammunition,
    bool? isActive,
    String? notes,
    String? serialNumber,
    String? overallLength,
    String? weight,
    String? capacity,
    String? finish,
    String? sightType,
    String? sightOptic,
    String? sightModel,
    String? sightHeight,
    String? purchaseDate,
    String? modifications,
    // ✅ Clear parameters for removing associations
    bool clearScope = false,
    bool clearAmmunition = false,
  }) {
    return Rifle(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      manufacturer: manufacturer ?? this.manufacturer,
      generationVariant: generationVariant ?? this.generationVariant,
      model: model ?? this.model,
      caliber: caliber ?? this.caliber,
      barrel: barrel ?? this.barrel,
      action: action ?? this.action,
      stock: stock ?? this.stock,
      // ✅ Handle scope clearing
      scope: clearScope ? null : (scope ?? this.scope),
      // ✅ Handle ammunition clearing
      ammunition: clearAmmunition ? null : (ammunition ?? this.ammunition),
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      serialNumber: serialNumber ?? this.serialNumber,
      overallLength: overallLength ?? this.overallLength,
      weight: weight ?? this.weight,
      capacity: capacity ?? this.capacity,
      finish: finish ?? this.finish,
      sightType: sightType ?? this.sightType,
      sightOptic: sightOptic ?? this.sightOptic,
      sightModel: sightModel ?? this.sightModel,
      sightHeight: sightHeight ?? this.sightHeight,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      modifications: modifications ?? this.modifications,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    brand,
    manufacturer,
    generationVariant,
    model,
    caliber,
    barrel,
    action,
    stock,
    scope,
    ammunition,
    isActive,
    notes,
    serialNumber,
    overallLength,
    weight,
    capacity,
    finish,
    sightType,
    sightOptic,
    sightModel,
    sightHeight,
    purchaseDate,
    modifications,
  ];
}

class Barrel extends Equatable {
  final String? length;
  final String? twist;
  final String? threading;
  final String? material;
  final String? profile;

  const Barrel({
    this.length,
    this.twist,
    this.threading,
    this.material,
    this.profile,
  });

  @override
  List<Object?> get props => [length, twist, threading, material, profile];
}

class RAAction extends Equatable {
  final String? type;
  final String? trigger;
  final String? triggerWeight;

  const RAAction({
    this.type,
    this.trigger,
    this.triggerWeight,
  });

  @override
  List<Object?> get props => [type, trigger, triggerWeight];
}

class Stock extends Equatable {
  final String? manufacturer;
  final String? model;
  final bool adjustableLOP;
  final bool adjustableCheekRest;

  const Stock({
    this.manufacturer,
    this.model,
    required this.adjustableLOP,
    required this.adjustableCheekRest,
  });

  @override
  List<Object?> get props => [manufacturer, model, adjustableLOP, adjustableCheekRest];
}