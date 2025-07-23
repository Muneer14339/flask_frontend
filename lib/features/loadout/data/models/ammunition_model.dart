// lib/features/Loadout/data/models/ammunition_model.dart
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ammunition.dart';

// part 'ammunition_model.g.dart';

@HiveType(typeId: 4)
class AmmunitionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String manufacturer;

  @HiveField(3)
  String caliber;

  @HiveField(4)
  BulletModel bullet;

  @HiveField(5)
  String? powder;

  @HiveField(6)
  String? primer;

  @HiveField(7)
  String? brass;

  @HiveField(8)
  int? velocity;

  @HiveField(9)
  int? es;

  @HiveField(10)
  int? sd;

  @HiveField(11)
  String? lotNumber;

  @HiveField(12)
  int count;

  @HiveField(13)
  double? price;

  @HiveField(14)
  bool tempStable;

  @HiveField(15)
  String? notes;

  // Advanced fields
  @HiveField(16)
  String? cartridgeType;

  @HiveField(17)
  String? caseMaterial;

  @HiveField(18)
  String? primerType;

  @HiveField(19)
  String? pressureClass;

  @HiveField(20)
  double? sectionalDensity;

  @HiveField(21)
  double? recoilEnergy;

  @HiveField(22)
  double? powderCharge;

  @HiveField(23)
  String? powderType;

  @HiveField(24)
  int? chronographFPS;

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
    // Advanced fields
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
      // Advanced fields
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

  // Firestore serialization methods
  factory AmmunitionModel.fromFirestore(Map<String, dynamic> data, String id) {
    return AmmunitionModel(
      id: data['id'] ?? id,
      name: data['name'] ?? '',
      manufacturer: data['manufacturer'] ?? '',
      caliber: data['caliber'] ?? '',
      bullet: BulletModel.fromFirestore(data['bullet'] ?? {}),
      powder: data['powder'],
      primer: data['primer'],
      brass: data['brass'],
      velocity: data['velocity'],
      es: data['es'],
      sd: data['sd'],
      lotNumber: data['lotNumber'],
      count: data['count'] ?? 0,
      price: data['price']?.toDouble(),
      tempStable: data['tempStable'] ?? false,
      notes: data['notes'],
      // Advanced fields
      cartridgeType: data['cartridgeType'],
      caseMaterial: data['caseMaterial'],
      primerType: data['primerType'],
      pressureClass: data['pressureClass'],
      sectionalDensity: data['sectionalDensity']?.toDouble(),
      recoilEnergy: data['recoilEnergy']?.toDouble(),
      powderCharge: data['powderCharge']?.toDouble(),
      powderType: data['powderType'],
      chronographFPS: data['chronographFPS'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'manufacturer': manufacturer,
      'caliber': caliber,
      'bullet': bullet.toFirestore(),
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
      // Advanced fields
      'cartridgeType': cartridgeType,
      'caseMaterial': caseMaterial,
      'primerType': primerType,
      'pressureClass': pressureClass,
      'sectionalDensity': sectionalDensity,
      'recoilEnergy': recoilEnergy,
      'powderCharge': powderCharge,
      'powderType': powderType,
      'chronographFPS': chronographFPS,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
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
      // Advanced fields
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

@HiveType(typeId: 5)
class BulletModel extends HiveObject {
  @HiveField(0)
  String? weight;

  @HiveField(1)
  String? type;

  @HiveField(2)
  String? manufacturer;

  @HiveField(3)
  BallisticCoefficientModel bc;

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

  // Firestore methods
  factory BulletModel.fromFirestore(Map<String, dynamic> data) {
    return BulletModel(
      weight: data['weight'],
      type: data['type'],
      manufacturer: data['manufacturer'],
      bc: BallisticCoefficientModel.fromFirestore(data['bc'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'weight': weight,
      'type': type,
      'manufacturer': manufacturer,
      'bc': bc.toFirestore(),
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

@HiveType(typeId: 6)
class BallisticCoefficientModel extends HiveObject {
  @HiveField(0)
  double? g1;

  @HiveField(1)
  double? g7;

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

  // Firestore methods
  factory BallisticCoefficientModel.fromFirestore(Map<String, dynamic> data) {
    return BallisticCoefficientModel(
      g1: data['g1']?.toDouble(),
      g7: data['g7']?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
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