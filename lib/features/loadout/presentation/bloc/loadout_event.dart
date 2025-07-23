// lib/features/Loadout/presentation/bloc/Loadout_event.dart - Final Updated

part of 'loadout_bloc.dart';

abstract class LoadoutEvent extends Equatable {
  const LoadoutEvent();

  @override
  List<Object?> get props => [];
}

class LoadLoadoutEvent extends LoadoutEvent {}

class AddRifleEvent extends LoadoutEvent {
  final Rifle rifle;

  const AddRifleEvent(this.rifle);

  @override
  List<Object> get props => [rifle];
}

class AddAmmunitionEvent extends LoadoutEvent {
  final Ammunition ammunition;

  const AddAmmunitionEvent(this.ammunition);

  @override
  List<Object> get props => [ammunition];
}

class AddScopeEvent extends LoadoutEvent {
  final Scope scope;

  const AddScopeEvent(this.scope);

  @override
  List<Object> get props => [scope];
}

class AddMaintenanceEvent extends LoadoutEvent {
  final Maintenance maintenance;

  const AddMaintenanceEvent(this.maintenance);

  @override
  List<Object> get props => [maintenance];
}

class SetActiveRifleEvent extends LoadoutEvent {
  final String rifleId;

  const SetActiveRifleEvent(this.rifleId);

  @override
  List<Object> get props => [rifleId];
}

class DeleteAmmunitionEvent extends LoadoutEvent {
  final String ammunitionId;

  const DeleteAmmunitionEvent(this.ammunitionId);

  @override
  List<Object> get props => [ammunitionId];
}


class DeleteMaintenanceEvent extends LoadoutEvent {
  final String maintenanceId;

  const DeleteMaintenanceEvent(this.maintenanceId);

  @override
  List<Object> get props => [maintenanceId];
}

class DeleteScopeEvent extends LoadoutEvent {
  final String scopeId;

  const DeleteScopeEvent(this.scopeId);

  @override
  List<Object> get props => [scopeId];
}


class CompleteMaintenanceEvent extends LoadoutEvent {
  final String maintenanceId;

  const CompleteMaintenanceEvent(this.maintenanceId);

  @override
  List<Object> get props => [maintenanceId];
}

// Update Events for Rifle associations
class UpdateRifleScopeEvent extends LoadoutEvent {
  final String rifleId;
  final Scope? scope;

  const UpdateRifleScopeEvent({
    required this.rifleId,
    this.scope,
  });

  @override
  List<Object?> get props => [rifleId, scope];
}

class UpdateRifleAmmunitionEvent extends LoadoutEvent {
  final String rifleId;
  final Ammunition? ammunition;

  const UpdateRifleAmmunitionEvent({
    required this.rifleId,
    this.ammunition,
  });

  @override
  List<Object?> get props => [rifleId, ammunition];
}

class UpdateRifleEvent extends LoadoutEvent {
  final Rifle rifle;

  const UpdateRifleEvent(this.rifle);

  @override
  List<Object> get props => [rifle];
}

// NEW: Direct Update Events for Scope and Ammunition
class UpdateScopeEvent extends LoadoutEvent {
  final Scope scope;

  const UpdateScopeEvent(this.scope);

  @override
  List<Object> get props => [scope];
}

class UpdateAmmunitionEvent extends LoadoutEvent {
  final Ammunition ammunition;

  const UpdateAmmunitionEvent(this.ammunition);

  @override
  List<Object> get props => [ammunition];
}