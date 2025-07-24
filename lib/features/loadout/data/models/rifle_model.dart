// lib/features/loadout/data/models/rifle_model.dart
import '../../domain/entities/rifle.dart';
import 'scope_model.dart';
import 'ammunition_model.dart';

class RifleModel {
  final String id;
  final String name;
  final String brand;
  final String manufacturer;
  final String generationVariant;
  final String model;
  final String caliber;
  final BarrelModel barrel;
  final ActionModel action;
  final StockModel stock;
  final ScopeModel? scope;
  final AmmunitionModel? ammunition;
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

  factory RifleModel.fromJson(Map<String, dynamic> json) {
    return RifleModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      generationVariant: json['generationVariant'] ?? '',
      model: json['model'] ?? '',
      caliber: json['caliber'] ?? '',
      barrel: BarrelModel.fromJson(json['barrel'] ?? {}),
      action: ActionModel.fromJson(json['action'] ?? {}),
      stock: StockModel.fromJson(json['stock'] ?? {}),
      scope: json['scope'] != null ? ScopeModel.fromJson(json['scope']) : null,
      ammunition: json['ammunition'] != null ? AmmunitionModel.fromJson(json['ammunition']) : null,
      isActive: json['isActive'] ?? false,
      notes: json['notes'],
      serialNumber: json['serialNumber'],
      overallLength: json['overallLength'],
      weight: json['weight'],
      capacity: json['capacity'],
      finish: json['finish'],
      sightType: json['sightType'],
      sightOptic: json['sightOptic'],
      sightModel: json['sightModel'],
      sightHeight: json['sightHeight'],
      purchaseDate: json['purchaseDate'],
      modifications: json['modifications'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'manufacturer': manufacturer,
      'generationVariant': generationVariant,
      'model': model,
      'caliber': caliber,
      'barrel': barrel.toJson(),
      'action': action.toJson(),
      'stock': stock.toJson(),

      // ✅ FIXED: Include both full objects AND IDs for backend compatibility
      'scope': scope?.toJson(),
      'ammunition': ammunition?.toJson(),
      'scopeId': scope?.id, // ← This is what the backend needs!
      'ammunitionId': ammunition?.id, // ← This is what the backend needs!

      'isActive': isActive,
      'notes': notes,
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

class BarrelModel {
  final String? length;
  final String? twist;
  final String? threading;
  final String? material;
  final String? profile;

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

  factory BarrelModel.fromJson(Map<String, dynamic> json) {
    return BarrelModel(
      length: json['length'],
      twist: json['twist'],
      threading: json['threading'],
      material: json['material'],
      profile: json['profile'],
    );
  }

  Map<String, dynamic> toJson() {
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

class ActionModel {
  final String? type;
  final String? trigger;
  final String? triggerWeight;

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

  factory ActionModel.fromJson(Map<String, dynamic> json) {
    return ActionModel(
      type: json['type'],
      trigger: json['trigger'],
      triggerWeight: json['triggerWeight'],
    );
  }

  Map<String, dynamic> toJson() {
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

class StockModel {
  final String? manufacturer;
  final String? model;
  final bool adjustableLOP;
  final bool adjustableCheekRest;

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

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      manufacturer: json['manufacturer'],
      model: json['model'],
      adjustableLOP: json['adjustableLOP'] ?? false,
      adjustableCheekRest: json['adjustableCheekRest'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
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