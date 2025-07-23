import 'package:equatable/equatable.dart';

class Ammunition extends Equatable {
  final String id;
  final String name;
  final String manufacturer;
  final String caliber;
  final Bullet bullet;

  // Basic load data
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

  // Advanced fields from HTML
  final String? cartridgeType;      // Factory, Reload, Mil-Surp
  final String? caseMaterial;       // Brass, Steel, Nickel
  final String? primerType;         // Boxer, Berdan, Match
  final String? pressureClass;      // NATO, SAAMI, +P
  final double? sectionalDensity;   // Sectional Density
  final double? recoilEnergy;       // Recoil Energy (ft-lbs)
  final double? powderCharge;       // Powder Charge (grains)
  final String? powderType;         // Powder Type
  final int? chronographFPS;        // Chronograph FPS (optional)

  const Ammunition({
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

  Ammunition copyWith({
    String? id,
    String? name,
    String? manufacturer,
    String? caliber,
    Bullet? bullet,
    String? powder,
    String? primer,
    String? brass,
    int? velocity,
    int? es,
    int? sd,
    String? lotNumber,
    int? count,
    double? price,
    bool? tempStable,
    String? notes,
    String? cartridgeType,
    String? caseMaterial,
    String? primerType,
    String? pressureClass,
    double? sectionalDensity,
    double? recoilEnergy,
    double? powderCharge,
    String? powderType,
    int? chronographFPS,
  }) {
    return Ammunition(
      id: id ?? this.id,
      name: name ?? this.name,
      manufacturer: manufacturer ?? this.manufacturer,
      caliber: caliber ?? this.caliber,
      bullet: bullet ?? this.bullet,
      powder: powder ?? this.powder,
      primer: primer ?? this.primer,
      brass: brass ?? this.brass,
      velocity: velocity ?? this.velocity,
      es: es ?? this.es,
      sd: sd ?? this.sd,
      lotNumber: lotNumber ?? this.lotNumber,
      count: count ?? this.count,
      price: price ?? this.price,
      tempStable: tempStable ?? this.tempStable,
      notes: notes ?? this.notes,
      cartridgeType: cartridgeType ?? this.cartridgeType,
      caseMaterial: caseMaterial ?? this.caseMaterial,
      primerType: primerType ?? this.primerType,
      pressureClass: pressureClass ?? this.pressureClass,
      sectionalDensity: sectionalDensity ?? this.sectionalDensity,
      recoilEnergy: recoilEnergy ?? this.recoilEnergy,
      powderCharge: powderCharge ?? this.powderCharge,
      powderType: powderType ?? this.powderType,
      chronographFPS: chronographFPS ?? this.chronographFPS,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    manufacturer,
    caliber,
    bullet,
    powder,
    primer,
    brass,
    velocity,
    es,
    sd,
    lotNumber,
    count,
    price,
    tempStable,
    notes,
    cartridgeType,
    caseMaterial,
    primerType,
    pressureClass,
    sectionalDensity,
    recoilEnergy,
    powderCharge,
    powderType,
    chronographFPS,
  ];
}

class Bullet extends Equatable {
  final String? weight;
  final String? type;
  final String? manufacturer;
  final BallisticCoefficient bc;

  const Bullet({
    this.weight,
    this.type,
    this.manufacturer,
    required this.bc,
  });

  Bullet copyWith({
    String? weight,
    String? type,
    String? manufacturer,
    BallisticCoefficient? bc,
  }) {
    return Bullet(
      weight: weight ?? this.weight,
      type: type ?? this.type,
      manufacturer: manufacturer ?? this.manufacturer,
      bc: bc ?? this.bc,
    );
  }

  @override
  List<Object?> get props => [weight, type, manufacturer, bc];
}

class BallisticCoefficient extends Equatable {
  final double? g1;
  final double? g7;

  const BallisticCoefficient({
    this.g1,
    this.g7,
  });

  BallisticCoefficient copyWith({
    double? g1,
    double? g7,
  }) {
    return BallisticCoefficient(
      g1: g1 ?? this.g1,
      g7: g7 ?? this.g7,
    );
  }

  @override
  List<Object?> get props => [g1, g7];
}