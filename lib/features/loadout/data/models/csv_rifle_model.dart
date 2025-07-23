import 'package:equatable/equatable.dart';

class CSVRifleModel extends Equatable {
  final String name;
  final String brand;
  final String model;
  final String generationVariant;
  final String caliber;
  final String actionType;
  final String manufacturer;
  final String notes;

  const CSVRifleModel({
    required this.name,
    required this.brand,
    required this.model,
    required this.generationVariant,
    required this.caliber,
    required this.actionType,
    required this.manufacturer,
    required this.notes,
  });

  @override
  List<Object> get props => [
    name,
    brand,
    model,
    generationVariant,
    caliber,
    actionType,
    manufacturer,
    notes
  ];

  CSVRifleModel copyWith({
    String? name,
    String? brand,
    String? model,
    String? generationVariant,
    String? caliber,
    String? actionType,
    String? manufacturer,
    String? notes,
  }) {
    return CSVRifleModel(
      name: name ?? this.name,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      generationVariant: generationVariant ?? this.generationVariant,
      caliber: caliber ?? this.caliber,
      actionType: actionType ?? this.actionType,
      manufacturer: manufacturer ?? this.manufacturer,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'brand': brand,
      'model': model,
      'generationVariant': generationVariant,
      'caliber': caliber,
      'actionType': actionType,
      'manufacturer': manufacturer,
      'notes': notes,
    };
  }

  factory CSVRifleModel.fromJson(Map<String, dynamic> json) {
    return CSVRifleModel(
      name: json['name'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      generationVariant: json['generationVariant'] as String,
      caliber: json['caliber'] as String,
      actionType: json['actionType'] as String,
      manufacturer: json['manufacturer'] as String,
      notes: json['notes'] as String,
    );
  }
}