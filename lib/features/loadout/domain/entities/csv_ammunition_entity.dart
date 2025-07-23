import 'package:equatable/equatable.dart';

class CSVAmmunitionEntity extends Equatable {
  final String ammunitionName;
  final String manufacturer;
  final String caliber;

  const CSVAmmunitionEntity({
    required this.ammunitionName,
    required this.manufacturer,
    required this.caliber,
  });

  @override
  List<Object> get props => [ammunitionName, manufacturer, caliber];
}