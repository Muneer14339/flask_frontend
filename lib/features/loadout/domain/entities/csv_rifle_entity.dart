import 'package:equatable/equatable.dart';

class CSVRifleEntity extends Equatable {
  final String rifleName;
  final String manufacturer;
  final String model;
  final String caliber;
  final String notes;

  const CSVRifleEntity({
    required this.rifleName,
    required this.manufacturer,
    required this.model,
    required this.caliber,
    required this.notes,
  });

  @override
  List<Object> get props => [rifleName, manufacturer, model, caliber, notes];
}