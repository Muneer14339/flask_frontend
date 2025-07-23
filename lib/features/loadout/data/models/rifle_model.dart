// lib/features/Loadout/data/models/rifle_model.dart
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/rifle.dart';
import 'scope_model.dart';
import 'ammunition_model.dart';

// part 'rifle_model.g.dart';

@HiveType(typeId: 0)
class RifleModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String brand;

  @HiveField(3)
  String manufacturer;

  @HiveField(4)
  String generationVariant;

  @HiveField(5)
  String model;

  @HiveField(6)
  String caliber;

  @HiveField(7)
  BarrelModel barrel;

  @HiveField(8)
  ActionModel action;

  @HiveField(9)
  StockModel stock;

  @HiveField(10)
  ScopeModel? scope;

  @HiveField(11)
  AmmunitionModel? ammunition;

  @HiveField(13)
  bool isActive;

  @HiveField(14)
  String? notes;

  // New advanced fields - starting from field 14
  @HiveField(15)
  String? serialNumber;

  @HiveField(16)
  String? overallLength;

  @HiveField(17)
  String? weight;

  @HiveField(18)
  String? capacity;

  @HiveField(19)
  String? finish;

  @HiveField(20)
  String? sightType;

  @HiveField(21)
  String? sightOptic;

  @HiveField(22)
  String? sightModel;

  @HiveField(23)
  String? sightHeight;

  @HiveField(24)
  String? purchaseDate;

  @HiveField(25)
  String? modifications;

  RifleModel({
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
    // New advanced fields
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

  factory RifleModel.fromEntity(Rifle rifle) {
    return RifleModel(
      id: rifle.id,
      name: rifle.name,
      brand: rifle.brand,
      manufacturer: rifle.manufacturer,
      generationVariant: rifle.generationVariant,
      model: rifle.model,
      caliber: rifle.caliber,
      barrel: BarrelModel.fromEntity(rifle.barrel),
      action: ActionModel.fromEntity(rifle.action),
      stock: StockModel.fromEntity(rifle.stock),
      scope: rifle.scope != null ? ScopeModel.fromEntity(rifle.scope!) : null,
      ammunition: rifle.ammunition != null ? AmmunitionModel.fromEntity(rifle.ammunition!) : null,
      isActive: rifle.isActive,
      notes: rifle.notes,
      // New advanced fields
      serialNumber: rifle.serialNumber,
      overallLength: rifle.overallLength,
      weight: rifle.weight,
      capacity: rifle.capacity,
      finish: rifle.finish,
      sightType: rifle.sightType,
      sightOptic: rifle.sightOptic,
      sightModel: rifle.sightModel,
      sightHeight: rifle.sightHeight,
      purchaseDate: rifle.purchaseDate,
      modifications: rifle.modifications,
    );
  }

  // NEW: Firestore serialization methods
  factory RifleModel.fromFirestore(Map<String, dynamic> data, String id) {
    return RifleModel(
      id: id,
      name: data['name'] ?? '',
      brand: data['brand'] ?? '',
      manufacturer: data['manufacturer'] ?? '',
      generationVariant: data['generationVariant;'] ?? '',
      model: data['model'] ?? '',
      caliber: data['caliber'] ?? '',
      barrel: BarrelModel.fromFirestore(data['barrel'] ?? {}),
      action: ActionModel.fromFirestore(data['action'] ?? {}),
      stock: StockModel.fromFirestore(data['stock'] ?? {}),
      scope: data['scope'] != null ? ScopeModel.fromFirestore(data['scope'], '') : null,
      ammunition: data['ammunition'] != null ? AmmunitionModel.fromFirestore(data['ammunition'], '') : null,
      isActive: data['isActive'] ?? false,
      notes: data['notes'],
      // New advanced fields
      serialNumber: data['serialNumber'],
      overallLength: data['overallLength'],
      weight: data['weight'],
      capacity: data['capacity'],
      finish: data['finish'],
      sightType: data['sightType'],
      sightOptic: data['sightOptic'],
      sightModel: data['sightModel'],
      sightHeight: data['sightHeight'],
      purchaseDate: data['purchaseDate'],
      modifications: data['modifications'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'brand': brand,
      'manufacturer': manufacturer,
      'generationVariant;': generationVariant,
      'model': model,
      'caliber': caliber,
      'barrel': barrel.toFirestore(),
      'action': action.toFirestore(),
      'stock': stock.toFirestore(),
      'scope': scope?.toFirestore(),
      'ammunition': ammunition?.toFirestore(),
      'isActive': isActive,
      'notes': notes,
      // New advanced fields
      'serialNumber': serialNumber,
      'overallLength': overallLength,
      'weight': weight,
      'capacity': capacity,
      'finish': finish,
      'sightType': sightType,
      'sightOptic': sightOptic,
      'sightModel': sightModel,
      'sightHeight': sightHeight,
      'purchaseDate': purchaseDate,
      'modifications': modifications,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Rifle toEntity() {
    return Rifle(
      id: id,
      name: name,
      brand: brand,
      manufacturer: manufacturer,
      generationVariant: generationVariant,
      model: model,
      caliber: caliber,
      barrel: barrel.toEntity(),
      action: action.toEntity(),
      stock: stock.toEntity(),
      scope: scope?.toEntity(),
      ammunition: ammunition?.toEntity(),
      isActive: isActive,
      notes: notes,
      // New advanced fields
      serialNumber: serialNumber,
      overallLength: overallLength,
      weight: weight,
      capacity: capacity,
      finish: finish,
      sightType: sightType,
      sightOptic: sightOptic,
      sightModel: sightModel,
      sightHeight: sightHeight,
      purchaseDate: purchaseDate,
      modifications: modifications,
    );
  }
}

@HiveType(typeId: 1)
class BarrelModel extends HiveObject {
  @HiveField(0)
  String? length;

  @HiveField(1)
  String? twist;

  @HiveField(2)
  String? threading;

  @HiveField(3)
  String? material;

  @HiveField(4)
  String? profile;

  BarrelModel({
    this.length,
    this.twist,
    this.threading,
    this.material,
    this.profile,
  });

  factory BarrelModel.fromEntity(Barrel barrel) {
    return BarrelModel(
      length: barrel.length,
      twist: barrel.twist,
      threading: barrel.threading,
      material: barrel.material,
      profile: barrel.profile,
    );
  }

  // NEW: Firestore methods
  factory BarrelModel.fromFirestore(Map<String, dynamic> data) {
    return BarrelModel(
      length: data['length'],
      twist: data['twist'],
      threading: data['threading'],
      material: data['material'],
      profile: data['profile'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'length': length,
      'twist': twist,
      'threading': threading,
      'material': material,
      'profile': profile,
    };
  }

  Barrel toEntity() {
    return Barrel(
      length: length,
      twist: twist,
      threading: threading,
      material: material,
      profile: profile,
    );
  }
}

@HiveType(typeId: 2)
class ActionModel extends HiveObject {
  @HiveField(0)
  String? type;

  @HiveField(1)
  String? trigger;

  @HiveField(2)
  String? triggerWeight;

  ActionModel({
    this.type,
    this.trigger,
    this.triggerWeight,
  });

  factory ActionModel.fromEntity(RAAction action) {
    return ActionModel(
      type: action.type,
      trigger: action.trigger,
      triggerWeight: action.triggerWeight,
    );
  }

  // NEW: Firestore methods
  factory ActionModel.fromFirestore(Map<String, dynamic> data) {
    return ActionModel(
      type: data['type'],
      trigger: data['trigger'],
      triggerWeight: data['triggerWeight'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'trigger': trigger,
      'triggerWeight': triggerWeight,
    };
  }

  RAAction toEntity() {
    return RAAction(
      type: type,
      trigger: trigger,
      triggerWeight: triggerWeight,
    );
  }
}

@HiveType(typeId: 3)
class StockModel extends HiveObject {
  @HiveField(0)
  String? manufacturer;

  @HiveField(1)
  String? model;

  @HiveField(2)
  bool adjustableLOP;

  @HiveField(3)
  bool adjustableCheekRest;

  StockModel({
    this.manufacturer,
    this.model,
    required this.adjustableLOP,
    required this.adjustableCheekRest,
  });

  factory StockModel.fromEntity(Stock stock) {
    return StockModel(
      manufacturer: stock.manufacturer,
      model: stock.model,
      adjustableLOP: stock.adjustableLOP,
      adjustableCheekRest: stock.adjustableCheekRest,
    );
  }

  // NEW: Firestore methods
  factory StockModel.fromFirestore(Map<String, dynamic> data) {
    return StockModel(
      manufacturer: data['manufacturer'],
      model: data['model'],
      adjustableLOP: data['adjustableLOP'] ?? false,
      adjustableCheekRest: data['adjustableCheekRest'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'manufacturer': manufacturer,
      'model': model,
      'adjustableLOP': adjustableLOP,
      'adjustableCheekRest': adjustableCheekRest,
    };
  }

  Stock toEntity() {
    return Stock(
      manufacturer: manufacturer,
      model: model,
      adjustableLOP: adjustableLOP,
      adjustableCheekRest: adjustableCheekRest,
    );
  }
}