part of 'loadout_bloc.dart';

abstract class LoadoutState extends Equatable {
  const LoadoutState();

  @override
  List<Object?> get props => [];
}

class LoadoutInitial extends LoadoutState {}

class LoadoutLoading extends LoadoutState {}

class LoadoutLoaded extends LoadoutState {
  final List<Rifle> rifles;
  final List<Ammunition> ammunition;
  final List<Scope> scopes;
  final List<Maintenance> maintenance;

  const LoadoutLoaded({
    required this.rifles,
    required this.ammunition,
    required this.scopes,
    required this.maintenance,
  });

  LoadoutLoaded copyWith({
    List<Rifle>? rifles,
    List<Ammunition>? ammunition,
    List<Scope>? scopes,
    List<Maintenance>? maintenance,
  }) {
    return LoadoutLoaded(
      rifles: rifles ?? this.rifles,
      ammunition: ammunition ?? this.ammunition,
      scopes: scopes ?? this.scopes,
      maintenance: maintenance ?? this.maintenance,
    );
  }

  int get rifleCount => rifles.length;
  int get ammoCount => ammunition.length;
  int get maintenanceDueCount => maintenance
      .where((m) {
    final status = _getMaintenanceStatus(m);
    return status == 'Due Soon' || status == 'Overdue';
  })
      .length;

  int get totalRounds => ammunition.fold(0, (sum, ammo) => sum + ammo.count);

  String _getMaintenanceStatus(Maintenance maintenance) {
    final now = DateTime.now();

    // Use createdAt when lastCompleted is null
    final referenceDate = maintenance.lastCompleted ?? maintenance.createdAt;
    if (referenceDate == null) {
      return 'New';
    }

    switch (maintenance.interval.unit) {
      case 'days':
        final daysDiff = now.difference(referenceDate).inDays;
        if (daysDiff > maintenance.interval.value) return 'Overdue';
        if (daysDiff > (maintenance.interval.value * 0.8)) return 'Due Soon';
        return 'OK';
      case 'weeks':
        final daysDiff = now.difference(referenceDate).inDays;
        final weeksDiff = daysDiff / 7;
        if (weeksDiff > maintenance.interval.value) return 'Overdue';
        if (weeksDiff > (maintenance.interval.value * 0.8)) return 'Due Soon';
        return 'OK';
      case 'months':
        final daysDiff = now.difference(referenceDate).inDays;
        final monthsDiff = daysDiff / 30;
        if (monthsDiff > maintenance.interval.value) return 'Overdue';
        if (monthsDiff > (maintenance.interval.value * 0.8)) return 'Due Soon';
        return 'OK';
      default:
        return 'Unknown';
    }
  }


  @override
  List<Object> get props => [rifles, ammunition, scopes, maintenance];
}

class LoadoutError extends LoadoutState {
  final String message;

  const LoadoutError(this.message);

  @override
  List<Object> get props => [message];
}
