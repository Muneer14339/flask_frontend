// lib/features/loadout/data/models/ammunition_model.dart
import '../../domain/entities/ammunition.dart';

class AmmunitionModel {
  final String id;
  final String name;
  final String manufacturer;
  final String caliber;
  final BulletModel bullet;
  final String? powder;
  final String? primer;
  final String? brass;
  final int? velocity;
  final int? es;
  final int? sd;
  final String? lotNumber;
  final int count;
  final double? price;
  final bool tempStable;
  final String? notes;

  // Advanced fields
  final String? cartridgeType;
  final String? caseMaterial;
  final String? primerType;
  final String? pressureClass;
  final double? sectionalDensity;
  final double? recoilEnergy;
  final double? powderCharge;
  final String? powderType;
  final int? chronographFPS;

  AmmunitionModel({
    required this.id,
    required this.name,
    required this.manufacturer,
    required this.caliber,
    required this.bullet,
    this.powder,
    this.primer,
    this.brass,
    this.velocity,
    this.es,
    this.sd,
    this.lotNumber,
    required this.count,
    this.price,
    required this.tempStable,
    this.notes,
    this.cartridgeType,
    this.caseMaterial,
    this.primerType,
    this.pressureClass,
    this.sectionalDensity,
    this.recoilEnergy,
    this.powderCharge,
    this.powderType,
    this.chronographFPS,
  });

  factory AmmunitionModel.fromEntity(Ammunition ammunition) {
    return AmmunitionModel(
      id: ammunition.id,
      name: ammunition.name,
      manufacturer: ammunition.manufacturer,
      caliber: ammunition.caliber,
      bullet: BulletModel.fromEntity(ammunition.bullet),
      powder: ammunition.powder,
      primer: ammunition.primer,
      brass: ammunition.brass,
      velocity: ammunition.velocity,
      es: ammunition.es,
      sd: ammunition.sd,
      lotNumber: ammunition.lotNumber,
      count: ammunition.count,
      price: ammunition.price,
      tempStable: ammunition.tempStable,
      notes: ammunition.notes,
      cartridgeType: ammunition.cartridgeType,
      caseMaterial: ammunition.caseMaterial,
      primerType: ammunition.primerType,
      pressureClass: ammunition.pressureClass,
      sectionalDensity: ammunition.sectionalDensity,
      recoilEnergy: ammunition.recoilEnergy,
      powderCharge: ammunition.powderCharge,
      powderType: ammunition.powderType,
      chronographFPS: ammunition.chronographFPS,
    );
  }

  factory AmmunitionModel.fromJson(Map<String, dynamic> json) {
    return AmmunitionModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      caliber: json['caliber'] ?? '',
      bullet: BulletModel.fromJson(json['bullet'] ?? {}),
      powder: json['powder'],
      primer: json['primer'],
      brass: json['brass'],
      velocity: json['velocity'],
      es: json['es'],
      sd: json['sd'],
      lotNumber: json['lotNumber'],
      count: json['count'] ?? 0,
      price: json['price']?.toDouble(),
      tempStable: json['tempStable'] ?? false,
      notes: json['notes'],
      cartridgeType: json['cartridgeType'],
      caseMaterial: json['caseMaterial'],
      primerType: json['primerType'],
      pressureClass: json['pressureClass'],
      sectionalDensity: json['sectionalDensity']?.toDouble(),
      recoilEnergy: json['recoilEnergy']?.toDouble(),
      powderCharge: json['powderCharge']?.toDouble(),
      powderType: json['powderType'],
      chronographFPS: json['chronographFPS'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'manufacturer': manufacturer,
      'caliber': caliber,
      'bullet': bullet.toJson(),
      'powder': powder,
      'primer': primer,
      'brass': brass,
      'velocity': velocity,
      'es': es,
      'sd': sd,
      'lotNumber': lotNumber,
      'count': count,
      'price': price,
      'tempStable': tempStable,
      'notes': notes,
      'cartridgeType': cartridgeType,
      'caseMaterial': caseMaterial,
      'primerType': primerType,
      'pressureClass': pressureClass,
      'sectionalDensity': sectionalDensity,
      'recoilEnergy': recoilEnergy,
      'powderCharge': powderCharge,
      'powderType': powderType,
      'chronographFPS': chronographFPS,
    };
  }

  Ammunition toEntity() {
    return Ammunition(
      id: id,
      name: name,
      manufacturer: manufacturer,
      caliber: caliber,
      bullet: bullet.toEntity(),
      powder: powder,
      primer: primer,
      brass: brass,
      velocity: velocity,
      es: es,
      sd: sd,
      lotNumber: lotNumber,
      count: count,
      price: price,
      tempStable: tempStable,
      notes: notes,
      cartridgeType: cartridgeType,
      caseMaterial: caseMaterial,
      primerType: primerType,
      pressureClass: pressureClass,
      sectionalDensity: sectionalDensity,
      recoilEnergy: recoilEnergy,
      powderCharge: powderCharge,
      powderType: powderType,
      chronographFPS: chronographFPS,
    );
  }
}

class BulletModel {
  final String? weight;
  final String? type;
  final String? manufacturer;
  final BallisticCoefficientModel bc;

  BulletModel({
    this.weight,
    this.type,
    this.manufacturer,
    required this.bc,
  });

  factory BulletModel.fromEntity(Bullet bullet) {
    return BulletModel(
      weight: bullet.weight,
      type: bullet.type,
      manufacturer: bullet.manufacturer,
      bc: BallisticCoefficientModel.fromEntity(bullet.bc),
    );
  }

  factory BulletModel.fromJson(Map<String, dynamic> json) {
    return BulletModel(
      weight: json['weight'],
      type: json['type'],
      manufacturer: json['manufacturer'],
      bc: BallisticCoefficientModel.fromJson(json['bc'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'type': type,
      'manufacturer': manufacturer,
      'bc': bc.toJson(),
    };
  }

  Bullet toEntity() {
    return Bullet(
      weight: weight,
      type: type,
      manufacturer: manufacturer,
      bc: bc.toEntity(),
    );
  }
}

class BallisticCoefficientModel {
  final double? g1;
  final double? g7;

  BallisticCoefficientModel({
    this.g1,
    this.g7,
  });

  factory BallisticCoefficientModel.fromEntity(BallisticCoefficient bc) {
    return BallisticCoefficientModel(
      g1: bc.g1,
      g7: bc.g7,
    );
  }

  factory BallisticCoefficientModel.fromJson(Map<String, dynamic> json) {
    return BallisticCoefficientModel(
      g1: json['g1']?.toDouble(),
      g7: json['g7']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'g1': g1,
      'g7': g7,
    };
  }

  BallisticCoefficient toEntity() {
    return BallisticCoefficient(
      g1: g1,
      g7: g7,
    );
  }
}