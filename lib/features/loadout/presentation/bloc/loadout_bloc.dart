// lib/features/loadout/presentation/bloc/loadout_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/error/failures.dart';
import '../../data/repositories/loadout_http_repository_impl.dart';
import '../../data/repositories/loadout_repository_impl.dart';
import '../../domain/entities/rifle.dart';
import '../../domain/entities/ammunition.dart';
import '../../domain/entities/scope.dart';
import '../../domain/entities/maintenance.dart';
import '../../domain/usecases/get_rifles.dart';
import '../../domain/usecases/add_rifle.dart';
import '../../domain/usecases/get_ammunition.dart';
import '../../domain/usecases/add_ammunition.dart';
import '../../domain/usecases/get_scopes.dart';
import '../../domain/usecases/add_scope.dart';
import '../../domain/usecases/get_maintenance.dart';
import '../../domain/usecases/add_maintenance.dart';
import '../../domain/usecases/delete_ammunition.dart';
import '../../domain/usecases/complete_maintenance.dart';
import '../../domain/usecases/delete_maintenance.dart';
import '../../domain/usecases/delete_scope.dart';
import '../../domain/usecases/update_rifle_scope.dart';
import '../../domain/usecases/update_rifle_ammunition.dart';
import '../../domain/usecases/update_rifle.dart';
import '../../domain/usecases/update_scope.dart';
import '../../domain/usecases/update_ammunition.dart';

part 'loadout_event.dart';
part 'loadout_state.dart';

class LoadoutBloc extends Bloc<LoadoutEvent, LoadoutState> {
  final GetRifles getRifles;
  final AddRifle addRifle;
  final GetAmmunition getAmmunition;
  final AddAmmunition addAmmunition;
  final GetScopes getScopes;
  final AddScope addScope;
  final GetMaintenance getMaintenance;
  final AddMaintenance addMaintenance;
  final DeleteAmmunition deleteAmmunition;
  final DeleteMaintenance deleteMaintenance;
  final DeleteScope deleteScope;
  final CompleteMaintenance completeMaintenance;
  final UpdateRifleScope updateRifleScope;
  final UpdateRifleAmmunition updateRifleAmmunition;
  final UpdateRifle updateRifle;
  final UpdateScope updateScope;
  final UpdateAmmunition updateAmmunition;

  // HTTP repository for real-time streams
  final LoadoutRepositoryImpl httpRepository;

  // Stream subscriptions
  StreamSubscription<dynamic>? _riflesSubscription;
  StreamSubscription<dynamic>? _ammunitionSubscription;
  StreamSubscription<dynamic>? _scopesSubscription;
  StreamSubscription<dynamic>? _maintenanceSubscription;

  LoadoutBloc({
    required this.getRifles,
    required this.addRifle,
    required this.getAmmunition,
    required this.addAmmunition,
    required this.getScopes,
    required this.addScope,
    required this.getMaintenance,
    required this.addMaintenance,
    required this.deleteAmmunition,
    required this.deleteScope,
    required this.completeMaintenance,
    required this.deleteMaintenance,
    required this.updateRifleScope,
    required this.updateRifleAmmunition,
    required this.updateRifle,
    required this.updateScope,
    required this.updateAmmunition,
    required this.httpRepository,
  }) : super(LoadoutInitial()) {
    on<LoadLoadoutEvent>(_onLoadLoadout);
    on<AddRifleEvent>(_onAddRifle);
    on<AddAmmunitionEvent>(_onAddAmmunition);
    on<AddScopeEvent>(_onAddScope);
    on<AddMaintenanceEvent>(_onAddMaintenance);
    on<SetActiveRifleEvent>(_onSetActiveRifle);
    on<DeleteAmmunitionEvent>(_onDeleteAmmunition);
    on<CompleteMaintenanceEvent>(_onCompleteMaintenance);
    on<DeleteMaintenanceEvent>(_onDeleteMaintenance);
    on<DeleteScopeEvent>(_onDeleteScope);
    on<UpdateRifleScopeEvent>(_onUpdateRifleScope);
    on<UpdateRifleAmmunitionEvent>(_onUpdateRifleAmmunition);
    on<UpdateRifleEvent>(_onUpdateRifle);
    on<UpdateScopeEvent>(_onUpdateScope);
    on<UpdateAmmunitionEvent>(_onUpdateAmmunition);

    // Stream events
    on<_RiflesUpdatedEvent>(_onRiflesUpdated);
    on<_AmmunitionUpdatedEvent>(_onAmmunitionUpdated);
    on<_ScopesUpdatedEvent>(_onScopesUpdated);
    on<_MaintenanceUpdatedEvent>(_onMaintenanceUpdated);
  }

  Future<void> _onLoadLoadout(LoadLoadoutEvent event, Emitter<LoadoutState> emit) async {
    emit(LoadoutLoading());

    try {
      // Start listening to real-time streams
      _startListeningToStreams();

      // Get initial data
      final riflesResult = await getRifles(NoParams());
      final ammunitionResult = await getAmmunition(NoParams());
      final scopesResult = await getScopes(NoParams());
      final maintenanceResult = await getMaintenance(NoParams());

      riflesResult.fold(
            (failure) => emit(LoadoutError(failure.toString())),
            (rifles) {
          ammunitionResult.fold(
                (failure) => emit(LoadoutError(failure.toString())),
                (ammunition) {
              scopesResult.fold(
                    (failure) => emit(LoadoutError(failure.toString())),
                    (scopes) {
                  maintenanceResult.fold(
                        (failure) => emit(LoadoutError(failure.toString())),
                        (maintenance) {
                      emit(LoadoutLoaded(
                        rifles: rifles,
                        ammunition: ammunition,
                        scopes: scopes,
                        maintenance: maintenance,
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
      emit(LoadoutError('Failed to load Loadout: $e'));
    }
  }

  // Start listening to HTTP streams (polling-based)
  void _startListeningToStreams() {
    // Listen to rifles stream
    _riflesSubscription = httpRepository.getRiflesStream().listen(
          (either) {
        either.fold(
              (failure) => add(_RiflesUpdatedEvent(failure: failure)),
              (rifles) => add(_RiflesUpdatedEvent(rifles: rifles)),
        );
      },
      onError: (error) {
        add(_RiflesUpdatedEvent(failure: DatabaseFailure('Stream error: $error')));
      },
    );

    // Listen to ammunition stream
    _ammunitionSubscription = httpRepository.getAmmunitionStream().listen(
          (either) {
        either.fold(
              (failure) => add(_AmmunitionUpdatedEvent(failure: failure)),
              (ammunition) => add(_AmmunitionUpdatedEvent(ammunition: ammunition)),
        );
      },
      onError: (error) {
        add(_AmmunitionUpdatedEvent(failure: DatabaseFailure('Stream error: $error')));
      },
    );

    // Listen to scopes stream
    _scopesSubscription = httpRepository.getScopesStream().listen(
          (either) {
        either.fold(
              (failure) => add(_ScopesUpdatedEvent(failure: failure)),
              (scopes) => add(_ScopesUpdatedEvent(scopes: scopes)),
        );
      },
      onError: (error) {
        add(_ScopesUpdatedEvent(failure: DatabaseFailure('Stream error: $error')));
      },
    );

    // Listen to maintenance stream
    _maintenanceSubscription = httpRepository.getMaintenanceStream().listen(
          (either) {
        either.fold(
              (failure) => add(_MaintenanceUpdatedEvent(failure: failure)),
              (maintenance) => add(_MaintenanceUpdatedEvent(maintenance: maintenance)),
        );
      },
      onError: (error) {
        add(_MaintenanceUpdatedEvent(failure: DatabaseFailure('Stream error: $error')));
      },
    );
  }

  // Handle real-time updates
  Future<void> _onRiflesUpdated(_RiflesUpdatedEvent event, Emitter<LoadoutState> emit) async {
    if (event.failure != null) {
      emit(LoadoutError(event.failure.toString()));
      return;
    }

    if (state is LoadoutLoaded && event.rifles != null) {
      final currentState = state as LoadoutLoaded;
      emit(currentState.copyWith(rifles: event.rifles));
    }
  }

  Future<void> _onAmmunitionUpdated(_AmmunitionUpdatedEvent event, Emitter<LoadoutState> emit) async {
    if (event.failure != null) {
      emit(LoadoutError(event.failure.toString()));
      return;
    }

    if (state is LoadoutLoaded && event.ammunition != null) {
      final currentState = state as LoadoutLoaded;
      emit(currentState.copyWith(ammunition: event.ammunition));
    }
  }

  Future<void> _onScopesUpdated(_ScopesUpdatedEvent event, Emitter<LoadoutState> emit) async {
    if (event.failure != null) {
      emit(LoadoutError(event.failure.toString()));
      return;
    }

    if (state is LoadoutLoaded && event.scopes != null) {
      final currentState = state as LoadoutLoaded;
      emit(currentState.copyWith(scopes: event.scopes));
    }
  }

  Future<void> _onMaintenanceUpdated(_MaintenanceUpdatedEvent event, Emitter<LoadoutState> emit) async {
    if (event.failure != null) {
      emit(LoadoutError(event.failure.toString()));
      return;
    }

    if (state is LoadoutLoaded && event.maintenance != null) {
      final currentState = state as LoadoutLoaded;
      emit(currentState.copyWith(maintenance: event.maintenance));
    }
  }

  Future<void> _onAddRifle(AddRifleEvent event, Emitter<LoadoutState> emit) async {
    final result = await addRifle(event.rifle);
    result.fold(
          (failure) => emit(LoadoutError(failure.toString())),
          (_) {
        print('✅ Rifle added successfully - real-time update will follow');
      },
    );
  }

  Future<void> _onAddAmmunition(AddAmmunitionEvent event, Emitter<LoadoutState> emit) async {
    final result = await addAmmunition(event.ammunition);
    result.fold(
          (failure) => emit(LoadoutError(failure.toString())),
          (_) {
        print('✅ Ammunition added successfully - real-time update will follow');
      },
    );
  }

  Future<void> _onAddScope(AddScopeEvent event, Emitter<LoadoutState> emit) async {
    final result = await addScope(event.scope);
    result.fold(
          (failure) => emit(LoadoutError(failure.toString())),
          (_) {
        print('✅ Scope added successfully - real-time update will follow');
      },
    );
  }

  Future<void> _onAddMaintenance(AddMaintenanceEvent event, Emitter<LoadoutState> emit) async {
    final result = await addMaintenance(event.maintenance);
    result.fold(
          (failure) => emit(LoadoutError(failure.toString())),
          (_) {
        print('✅ Maintenance task added successfully - real-time update will follow');
      },
    );
  }

  Future<void> _onSetActiveRifle(SetActiveRifleEvent event, Emitter<LoadoutState> emit) async {
    if (state is LoadoutLoaded) {
      final currentState = state as LoadoutLoaded;

      // Optimistic update for immediate UI response
      final updatedRifles = currentState.rifles.map((rifle) {
        return rifle.copyWith(isActive: rifle.id == event.rifleId);
      }).toList();

      emit(currentState.copyWith(rifles: updatedRifles));

      // Update in backend (real-time stream will handle the actual update)
      try {
        await httpRepository.setActiveRifle(event.rifleId);
      } catch (e) {
        // Revert optimistic update on error
        emit(currentState);
        emit(LoadoutError('Failed to set active rifle: $e'));
      }
    }
  }

  Future<void> _onDeleteAmmunition(DeleteAmmunitionEvent event, Emitter<LoadoutState> emit) async {
    final result = await deleteAmmunition(event.ammunitionId);
    result.fold(
          (failure) => emit(LoadoutError(failure.toString())),
          (_) {
        print('✅ Ammunition deleted successfully - real-time update will follow');
      },
    );
  }

  Future<void> _onCompleteMaintenance(CompleteMaintenanceEvent event, Emitter<LoadoutState> emit) async {
    final result = await completeMaintenance(event.maintenanceId);
    result.fold(
          (failure) => emit(LoadoutError(failure.toString())),
          (_) {
        print('✅ Maintenance completed successfully - real-time update will follow');
      },
    );
  }

  Future<void> _onDeleteScope(DeleteScopeEvent event, Emitter<LoadoutState> emit) async {
    final result = await deleteScope(event.scopeId);
    result.fold(
          (failure) => emit(LoadoutError(failure.toString())),
          (_) {
        print('✅ Scope deleted successfully - real-time update will follow');
      },
    );
  }

  Future<void> _onDeleteMaintenance(DeleteMaintenanceEvent event, Emitter<LoadoutState> emit) async {
    final result = await deleteMaintenance(event.maintenanceId);
    result.fold(
          (failure) => emit(LoadoutError(failure.toString())),
          (_) {
        print('✅ Maintenance deleted successfully - real-time update will follow');
      },
    );
  }

  Future<void> _onUpdateRifleScope(UpdateRifleScopeEvent event, Emitter<LoadoutState> emit) async {
    if (state is LoadoutLoaded) {
      final result = await updateRifleScope(UpdateRifleScopeParams(
        rifleId: event.rifleId,
        scope: event.scope,
      ));

      result.fold(
            (failure) => emit(LoadoutError(failure.toString())),
            (_) {
          print('✅ Scope update successful - real-time update will follow');
        },
      );
    }
  }

  Future<void> _onUpdateRifleAmmunition(UpdateRifleAmmunitionEvent event, Emitter<LoadoutState> emit) async {
    if (state is LoadoutLoaded) {
      final result = await updateRifleAmmunition(UpdateRifleAmmunitionParams(
        rifleId: event.rifleId,
        ammunition: event.ammunition,
      ));

      result.fold(
            (failure) => emit(LoadoutError(failure.toString())),
            (_) {
          print('✅ Ammunition update successful - real-time update will follow');
        },
      );
    }
  }

  Future<void> _onUpdateRifle(UpdateRifleEvent event, Emitter<LoadoutState> emit) async {
    final result = await updateRifle(event.rifle);
    result.fold(
          (failure) => emit(LoadoutError(failure.toString())),
          (_) {
        print('✅ Rifle update successful - real-time update will follow');
      },
    );
  }

  Future<void> _onUpdateScope(UpdateScopeEvent event, Emitter<LoadoutState> emit) async {
    final result = await updateScope(event.scope);
    result.fold(
          (failure) => emit(LoadoutError(failure.toString())),
          (_) {
        print('✅ Scope update successful - real-time update will follow');
      },
    );
  }

  Future<void> _onUpdateAmmunition(UpdateAmmunitionEvent event, Emitter<LoadoutState> emit) async {
    final result = await updateAmmunition(event.ammunition);
    result.fold(
          (failure) => emit(LoadoutError(failure.toString())),
          (_) {
        print('✅ Ammunition update successful - real-time update will follow');
      },
    );
  }

  @override
  Future<void> close() {
    // Cancel all stream subscriptions
    _riflesSubscription?.cancel();
    _ammunitionSubscription?.cancel();
    _scopesSubscription?.cancel();
    _maintenanceSubscription?.cancel();
    return super.close();
  }
}

// Internal events for stream updates
class _RiflesUpdatedEvent extends LoadoutEvent {
  final List<Rifle>? rifles;
  final Failure? failure;

  const _RiflesUpdatedEvent({this.rifles, this.failure});

  @override
  List<Object?> get props => [rifles, failure];
}

class _AmmunitionUpdatedEvent extends LoadoutEvent {
  final List<Ammunition>? ammunition;
  final Failure? failure;

  const _AmmunitionUpdatedEvent({this.ammunition, this.failure});

  @override
  List<Object?> get props => [ammunition, failure];
}

class _ScopesUpdatedEvent extends LoadoutEvent {
  final List<Scope>? scopes;
  final Failure? failure;

  const _ScopesUpdatedEvent({this.scopes, this.failure});

  @override
  List<Object?> get props => [scopes, failure];
}

class _MaintenanceUpdatedEvent extends LoadoutEvent {
  final List<Maintenance>? maintenance;
  final Failure? failure;

  const _MaintenanceUpdatedEvent({this.maintenance, this.failure});

  @override
  List<Object?> get props => [maintenance, failure];
}