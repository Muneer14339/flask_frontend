part of 'ballistic_bloc.dart';

abstract class BallisticEvent extends Equatable {
  const BallisticEvent();

  @override
  List<Object?> get props => [];
}

class LoadBallisticDataEvent extends BallisticEvent {
  final String rifleId;

  const LoadBallisticDataEvent(this.rifleId);

  @override
  List<Object> get props => [rifleId];
}

class SaveDopeEntryEvent extends BallisticEvent {
  final DopeEntry entry;

  const SaveDopeEntryEvent(this.entry);

  @override
  List<Object> get props => [entry];
}

class DeleteDopeEntryEvent extends BallisticEvent {
  final String entryId;

  const DeleteDopeEntryEvent(this.entryId);

  @override
  List<Object> get props => [entryId];
}

class SaveZeroEntryEvent extends BallisticEvent {
  final ZeroEntry entry;

  const SaveZeroEntryEvent(this.entry);

  @override
  List<Object> get props => [entry];
}

class DeleteZeroEntryEvent extends BallisticEvent {
  final String entryId;

  const DeleteZeroEntryEvent(this.entryId);

  @override
  List<Object> get props => [entryId];
}

class SaveChronographDataEvent extends BallisticEvent {
  final ChronographData data;

  const SaveChronographDataEvent(this.data);

  @override
  List<Object> get props => [data];
}

class DeleteChronographDataEvent extends BallisticEvent {
  final String dataId;

  const DeleteChronographDataEvent(this.dataId);

  @override
  List<Object> get props => [dataId];
}

class SaveBallisticCalculationEvent extends BallisticEvent {
  final BallisticCalculation calculation;

  const SaveBallisticCalculationEvent(this.calculation);

  @override
  List<Object> get props => [calculation];
}

class CalculateBallisticsEvent extends BallisticEvent {
  final String rifleId;
  final String ammunitionId;
  final double ballisticCoefficient;
  final double muzzleVelocity;
  final int targetDistance;
  final double windSpeed;
  final double windDirection;

  const CalculateBallisticsEvent({
    required this.rifleId,
    required this.ammunitionId,
    required this.ballisticCoefficient,
    required this.muzzleVelocity,
    required this.targetDistance,
    required this.windSpeed,
    required this.windDirection,
  });

  @override
  List<Object> get props => [
    rifleId,
    ammunitionId,
    ballisticCoefficient,
    muzzleVelocity,
    targetDistance,
    windSpeed,
    windDirection,
  ];
}

class DeleteBallisticCalculationEvent extends BallisticEvent {
  final String calculationId;

  const DeleteBallisticCalculationEvent(this.calculationId);

  @override
  List<Object> get props => [calculationId];
}