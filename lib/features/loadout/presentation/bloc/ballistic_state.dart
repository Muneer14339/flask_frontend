part of 'ballistic_bloc.dart';

abstract class BallisticState extends Equatable {
  const BallisticState();

  @override
  List<Object?> get props => [];
}

class BallisticInitial extends BallisticState {}

class BallisticLoading extends BallisticState {}

class BallisticLoaded extends BallisticState {
  final List<DopeEntry> dopeEntries;
  final List<ZeroEntry> zeroEntries;
  final List<ChronographData> chronographData;
  final List<BallisticCalculation> ballisticCalculations;

  const BallisticLoaded({
    required this.dopeEntries,
    required this.zeroEntries,
    required this.chronographData,
    required this.ballisticCalculations,
  });

  BallisticLoaded copyWith({
    List<DopeEntry>? dopeEntries,
    List<ZeroEntry>? zeroEntries,
    List<ChronographData>? chronographData,
    List<BallisticCalculation>? ballisticCalculations,
  }) {
    return BallisticLoaded(
      dopeEntries: dopeEntries ?? this.dopeEntries,
      zeroEntries: zeroEntries ?? this.zeroEntries,
      chronographData: chronographData ?? this.chronographData,
      ballisticCalculations: ballisticCalculations ?? this.ballisticCalculations,
    );
  }

  @override
  List<Object> get props => [
    dopeEntries,
    zeroEntries,
    chronographData,
    ballisticCalculations,
  ];
}

class BallisticError extends BallisticState {
  final String message;

  const BallisticError(this.message);

  @override
  List<Object> get props => [message];
}