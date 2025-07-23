import 'package:equatable/equatable.dart';

class PositionPreset extends Equatable {
  final String id;
  final String name;
  final String description;
  final double cantTolerance;
  final double tiltTolerance;
  final double panTolerance;

  const PositionPreset({
    required this.id,
    required this.name,
    required this.description,
    required this.cantTolerance,
    required this.tiltTolerance,
    required this.panTolerance,
  });

  static const List<PositionPreset> presets = [
    PositionPreset(
      id: 'precision',
      name: 'Precision Lab',
      description: '±0.1° cant, ±0.1° tilt',
      cantTolerance: 0.1,
      tiltTolerance: 0.1,
      panTolerance: 2.0,
    ),
    PositionPreset(
      id: 'benchrest',
      name: 'Benchrest',
      description: '±0.5° cant, ±1.0° tilt',
      cantTolerance: 0.5,
      tiltTolerance: 1.0,
      panTolerance: 2.0,
    ),
    PositionPreset(
      id: 'prone',
      name: 'Prone',
      description: '±1.0° cant, ±2.0° tilt',
      cantTolerance: 1.0,
      tiltTolerance: 2.0,
      panTolerance: 2.0,
    ),
    PositionPreset(
      id: 'kneeling',
      name: 'Kneeling',
      description: '±1.5° cant, ±2.0° tilt',
      cantTolerance: 1.5,
      tiltTolerance: 2.0,
      panTolerance: 2.0,
    ),
    PositionPreset(
      id: 'standing',
      name: 'Standing',
      description: '±3.0° cant, ±5.0° tilt',
      cantTolerance: 3.0,
      tiltTolerance: 5.0,
      panTolerance: 2.0,
    ),
    PositionPreset(
      id: 'field',
      name: 'Field/Offhand',
      description: '±3.0° cant, ±4.0° tilt',
      cantTolerance: 3.0,
      tiltTolerance: 4.0,
      panTolerance: 2.0,
    ),
    PositionPreset(
      id: 'custom',
      name: 'Custom',
      description: 'Custom tolerances',
      cantTolerance: 2.0,
      tiltTolerance: 2.0,
      panTolerance: 2.0,
    ),
  ];

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    cantTolerance,
    tiltTolerance,
    panTolerance,
  ];
}