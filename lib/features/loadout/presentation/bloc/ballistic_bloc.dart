// lib/features/loadout/presentation/bloc/ballistic_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/ballistic_data.dart';
import '../../domain/usecases/ballistic_usecases.dart';
import '../../data/repositories/ballistic_repository_impl.dart';

part 'ballistic_event.dart';
part 'ballistic_state.dart';

class BallisticBloc extends Bloc<BallisticEvent, BallisticState> {
  final SaveDopeEntry saveDopeEntry;
  final GetDopeEntries getDopeEntries;
  final DeleteDopeEntry deleteDopeEntry;
  final SaveZeroEntry saveZeroEntry;
  final GetZeroEntries getZeroEntries;
  final DeleteZeroEntry deleteZeroEntry;
  final SaveChronographData saveChronographData;
  final GetChronographData getChronographData;
  final DeleteChronographData deleteChronographData;
  final SaveBallisticCalculation saveBallisticCalculation;
  final GetBallisticCalculations getBallisticCalculations;
  final DeleteBallisticCalculation deleteBallisticCalculation;
  final CalculateBallistics calculateBallistics;

  // Firebase repository for real-time streams
  final BallisticRepositoryImpl ballisticRepository;

  // Stream subscriptions
  StreamSubscription<dynamic>? _dopeSubscription;
  StreamSubscription<dynamic>? _zeroSubscription;
  StreamSubscription<dynamic>? _chronographSubscription;
  StreamSubscription<dynamic>? _calculationSubscription;

  BallisticBloc({
    required this.saveDopeEntry,
    required this.getDopeEntries,
    required this.deleteDopeEntry,
    required this.saveZeroEntry,
    required this.getZeroEntries,
    required this.deleteZeroEntry,
    required this.saveChronographData,
    required this.getChronographData,
    required this.deleteChronographData,
    required this.saveBallisticCalculation,
    required this.getBallisticCalculations,
    required this.deleteBallisticCalculation,
    required this.calculateBallistics,
    required this.ballisticRepository,
  }) : super(BallisticInitial()) {
    on<LoadBallisticDataEvent>(_onLoadBallisticData);
    on<SaveDopeEntryEvent>(_onSaveDopeEntry);
    on<DeleteDopeEntryEvent>(_onDeleteDopeEntry);
    on<SaveZeroEntryEvent>(_onSaveZeroEntry);
    on<DeleteZeroEntryEvent>(_onDeleteZeroEntry);
    on<SaveChronographDataEvent>(_onSaveChronographData);
    on<DeleteChronographDataEvent>(_onDeleteChronographData);
    on<SaveBallisticCalculationEvent>(_onSaveBallisticCalculation);
    on<CalculateBallisticsEvent>(_onCalculateBallistics);
    on<DeleteBallisticCalculationEvent>(_onDeleteBallisticCalculation);

    // Stream events
    on<_DopeEntriesUpdatedEvent>(_onDopeEntriesUpdated);
    on<_ZeroEntriesUpdatedEvent>(_onZeroEntriesUpdated);
    on<_ChronographDataUpdatedEvent>(_onChronographDataUpdated);
    on<_BallisticCalculationsUpdatedEvent>(_onBallisticCalculationsUpdated);
  }

  Future<void> _onLoadBallisticData(LoadBallisticDataEvent event, Emitter<BallisticState> emit) async {
    emit(BallisticLoading());

    try {
      // Start listening to real-time streams
      _startListeningToStreams(event.rifleId);

      // Get initial data
      final dopeResult = await getDopeEntries(event.rifleId);
      final zeroResult = await getZeroEntries(event.rifleId);
      final chronoResult = await getChronographData(event.rifleId);
      final calculationResult = await getBallisticCalculations(event.rifleId);

      dopeResult.fold(
            (failure) => emit(BallisticError(failure.toString())),
            (dopeEntries) {
          zeroResult.fold(
                (failure) => emit(BallisticError(failure.toString())),
                (zeroEntries) {
              chronoResult.fold(
                    (failure) => emit(BallisticError(failure.toString())),
                    (chronographData) {
                  calculationResult.fold(
                        (failure) => emit(BallisticError(failure.toString())),
                        (calculations) {
                      emit(BallisticLoaded(
                        dopeEntries: dopeEntries,
                        zeroEntries: zeroEntries,
                        chronographData: chronographData,
                        ballisticCalculations: calculations,
                      ));
                    },
                  );
                },
              );
            },
          );
        },
      );
    } catch (e) {
      emit(BallisticError('Failed to load ballistic data: $e'));
    }
  }

  // Start listening to Firebase streams
  void _startListeningToStreams(String rifleId) {
    // Listen to DOPE entries stream
    _dopeSubscription = ballisticRepository.getDopeEntriesStream(rifleId)?.listen(
          (either) {
        either.fold(
              (failure) => add(_DopeEntriesUpdatedEvent(failure: failure)),
              (entries) => add(_DopeEntriesUpdatedEvent(dopeEntries: entries)),
        );
      },
      onError: (error) {
        add(_DopeEntriesUpdatedEvent(failure: DatabaseFailure('Stream error: $error')));
      },
    );

    // Listen to zero entries stream
    _zeroSubscription = ballisticRepository.getZeroEntriesStream(rifleId)?.listen(
          (either) {
        either.fold(
              (failure) => add(_ZeroEntriesUpdatedEvent(failure: failure)),
              (entries) => add(_ZeroEntriesUpdatedEvent(zeroEntries: entries)),
        );
      },
      onError: (error) {
        add(_ZeroEntriesUpdatedEvent(failure: DatabaseFailure('Stream error: $error')));
      },
    );

    // Listen to chronograph data stream
    _chronographSubscription = ballisticRepository.getChronographDataStream(rifleId)?.listen(
          (either) {
        either.fold(
              (failure) => add(_ChronographDataUpdatedEvent(failure: failure)),
              (data) => add(_ChronographDataUpdatedEvent(chronographData: data)),
        );
      },
      onError: (error) {
        add(_ChronographDataUpdatedEvent(failure: DatabaseFailure('Stream error: $error')));
      },
    );

    // Listen to ballistic calculations stream
    _calculationSubscription = ballisticRepository.getBallisticCalculationsStream(rifleId)?.listen(
          (either) {
        either.fold(
              (failure) => add(_BallisticCalculationsUpdatedEvent(failure: failure)),
              (calculations) => add(_BallisticCalculationsUpdatedEvent(calculations: calculations)),
        );
      },
      onError: (error) {
        add(_BallisticCalculationsUpdatedEvent(failure: DatabaseFailure('Stream error: $error')));
      },
    );
  }

  // Handle real-time updates
  Future<void> _onDopeEntriesUpdated(_DopeEntriesUpdatedEvent event, Emitter<BallisticState> emit) async {
    if (event.failure != null) {
      emit(BallisticError(event.failure.toString()));
      return;
    }

    if (state is BallisticLoaded && event.dopeEntries != null) {
      final currentState = state as BallisticLoaded;
      emit(currentState.copyWith(dopeEntries: event.dopeEntries));
    }
  }

  Future<void> _onZeroEntriesUpdated(_ZeroEntriesUpdatedEvent event, Emitter<BallisticState> emit) async {
    if (event.failure != null) {
      emit(BallisticError(event.failure.toString()));
      return;
    }

    if (state is BallisticLoaded && event.zeroEntries != null) {
      final currentState = state as BallisticLoaded;
      emit(currentState.copyWith(zeroEntries: event.zeroEntries));
    }
  }

  Future<void> _onChronographDataUpdated(_ChronographDataUpdatedEvent event, Emitter<BallisticState> emit) async {
    if (event.failure != null) {
      emit(BallisticError(event.failure.toString()));
      return;
    }

    if (state is BallisticLoaded && event.chronographData != null) {
      final currentState = state as BallisticLoaded;
      emit(currentState.copyWith(chronographData: event.chronographData));
    }
  }

  Future<void> _onBallisticCalculationsUpdated(_BallisticCalculationsUpdatedEvent event, Emitter<BallisticState> emit) async {
    if (event.failure != null) {
      emit(BallisticError(event.failure.toString()));
      return;
    }

    if (state is BallisticLoaded && event.calculations != null) {
      final currentState = state as BallisticLoaded;
      emit(currentState.copyWith(ballisticCalculations: event.calculations));
    }
  }

  Future<void> _onSaveDopeEntry(SaveDopeEntryEvent event, Emitter<BallisticState> emit) async {
    final result = await saveDopeEntry(event.entry);
    result.fold(
          (failure) => emit(BallisticError(failure.toString())),
          (_) {
        print('✅ DOPE entry saved successfully - real-time update will follow');
      },
    );
  }

  Future<void> _onDeleteDopeEntry(DeleteDopeEntryEvent event, Emitter<BallisticState> emit) async {
    final result = await deleteDopeEntry(event.entryId);
    result.fold(
          (failure) => emit(BallisticError(failure.toString())),
          (_) {
        print('✅ DOPE entry deleted successfully - real-time update will follow');
      },
    );
  }

  Future<void> _onSaveZeroEntry(SaveZeroEntryEvent event, Emitter<BallisticState> emit) async {
    final result = await saveZeroEntry(event.entry);
    result.fold(
          (failure) => emit(BallisticError(failure.toString())),
          (_) {
        print('✅ Zero entry saved successfully - real-time update will follow');
      },
    );
  }

  Future<void> _onDeleteZeroEntry(DeleteZeroEntryEvent event, Emitter<BallisticState> emit) async {
    final result = await deleteZeroEntry(event.entryId);
    result.fold(
          (failure) => emit(BallisticError(failure.toString())),
          (_) {
        print('✅ Zero entry deleted successfully - real-time update will follow');
      },
    );
  }

  Future<void> _onSaveChronographData(SaveChronographDataEvent event, Emitter<BallisticState> emit) async {
    final result = await saveChronographData(event.data);
    result.fold(
          (failure) => emit(BallisticError(failure.toString())),
          (_) {
        print('✅ Chronograph data saved successfully - real-time update will follow');
      },
    );
  }

  Future<void> _onDeleteChronographData(DeleteChronographDataEvent event, Emitter<BallisticState> emit) async {
    final result = await deleteChronographData(event.dataId);
    result.fold(
          (failure) => emit(BallisticError(failure.toString())),
          (_) {
        print('✅ Chronograph data deleted successfully - real-time update will follow');
      },
    );
  }

  Future<void> _onSaveBallisticCalculation(SaveBallisticCalculationEvent event, Emitter<BallisticState> emit) async {
    final result = await saveBallisticCalculation(event.calculation);
    result.fold(
          (failure) => emit(BallisticError(failure.toString())),
          (_) {
        print('✅ Ballistic calculation saved successfully - real-time update will follow');
      },
    );
  }

  Future<void> _onCalculateBallistics(CalculateBallisticsEvent event, Emitter<BallisticState> emit) async {
    final params = CalculateBallisticsParams(
      ballisticCoefficient: event.ballisticCoefficient,
      muzzleVelocity: event.muzzleVelocity,
      targetDistance: event.targetDistance,
      windSpeed: event.windSpeed,
      windDirection: event.windDirection,
    );

    final result = await calculateBallistics(params);
    result.fold(
          (failure) => emit(BallisticError(failure.toString())),
          (trajectoryData) {
        // Create and save ballistic calculation
        final calculation = BallisticCalculation(
          id: const Uuid().v4(),
          rifleId: event.rifleId,
          ammunitionId: event.ammunitionId,
          ballisticCoefficient: event.ballisticCoefficient,
          muzzleVelocity: event.muzzleVelocity,
          targetDistance: event.targetDistance,
          windSpeed: event.windSpeed,
          windDirection: event.windDirection,
          trajectoryData: trajectoryData,
          createdAt: DateTime.now(),
        );

        add(SaveBallisticCalculationEvent(calculation));
      },
    );
  }

  Future<void> _onDeleteBallisticCalculation(DeleteBallisticCalculationEvent event, Emitter<BallisticState> emit) async {
    final result = await deleteBallisticCalculation(event.calculationId);
    result.fold(
          (failure) => emit(BallisticError(failure.toString())),
          (_) {
        print('✅ Ballistic calculation deleted successfully - real-time update will follow');
      },
    );
  }

  @override
  Future<void> close() {
    // Cancel all stream subscriptions
    _dopeSubscription?.cancel();
    _zeroSubscription?.cancel();
    _chronographSubscription?.cancel();
    _calculationSubscription?.cancel();
    return super.close();
  }
}

// Internal events for stream updates
class _DopeEntriesUpdatedEvent extends BallisticEvent {
  final List<DopeEntry>? dopeEntries;
  final Failure? failure;

  const _DopeEntriesUpdatedEvent({this.dopeEntries, this.failure});

  @override
  List<Object?> get props => [dopeEntries, failure];
}

class _ZeroEntriesUpdatedEvent extends BallisticEvent {
  final List<ZeroEntry>? zeroEntries;
  final Failure? failure;

  const _ZeroEntriesUpdatedEvent({this.zeroEntries, this.failure});

  @override
  List<Object?> get props => [zeroEntries, failure];
}

class _ChronographDataUpdatedEvent extends BallisticEvent {
  final List<ChronographData>? chronographData;
  final Failure? failure;

  const _ChronographDataUpdatedEvent({this.chronographData, this.failure});

  @override
  List<Object?> get props => [chronographData, failure];
}

class _BallisticCalculationsUpdatedEvent extends BallisticEvent {
  final List<BallisticCalculation>? calculations;
  final Failure? failure;

  const _BallisticCalculationsUpdatedEvent({this.calculations, this.failure});

  @override
  List<Object?> get props => [calculations, failure];
}