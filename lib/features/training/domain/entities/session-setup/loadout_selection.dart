import 'package:equatable/equatable.dart';

class LoadoutSelection extends Equatable {
  final String? activeRifleId;

  const LoadoutSelection({
    this.activeRifleId,
  });

  bool get hasCompleteSetup =>
      activeRifleId != null;

  LoadoutSelection copyWith({
    String? activeRifleId,
    bool clearRifle = false,
  }) {
    return LoadoutSelection(
      activeRifleId: clearRifle ? null : (activeRifleId ?? this.activeRifleId),
    );
  }

  @override
  List<Object?> get props => [activeRifleId];
}