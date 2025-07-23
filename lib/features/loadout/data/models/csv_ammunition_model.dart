import 'package:equatable/equatable.dart';

class CSVAmmunitionModel extends Equatable {
  final String ammunitionName;
  final String manufacturer;
  final String caliber;

  const CSVAmmunitionModel({
    required this.ammunitionName,
    required this.manufacturer,
    required this.caliber,
  });

  @override
  List<Object> get props => [ammunitionName, manufacturer, caliber];

  CSVAmmunitionModel copyWith({
    String? ammunitionName,
    String? manufacturer,
    String? caliber,
  }) {
    return CSVAmmunitionModel(
      ammunitionName: ammunitionName ?? this.ammunitionName,
      manufacturer: manufacturer ?? this.manufacturer,
      caliber: caliber ?? this.caliber,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ammunitionName': ammunitionName,
      'manufacturer': manufacturer,
      'caliber': caliber,
    };
  }

  factory CSVAmmunitionModel.fromJson(Map<String, dynamic> json) {
    return CSVAmmunitionModel(
      ammunitionName: json['ammunitionName'] as String,
      manufacturer: json['manufacturer'] as String,
      caliber: json['caliber'] as String,
    );
  }
}