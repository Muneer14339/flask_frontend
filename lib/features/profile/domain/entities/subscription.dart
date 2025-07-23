import 'package:equatable/equatable.dart';

enum SubscriptionType { free, pro, premium }

class Subscription extends Equatable {
  final SubscriptionType type;
  final bool isActive;
  final DateTime? expiryDate;
  final int trainingSessionsLimit;
  final int trainingSessionsUsed;

  const Subscription({
    required this.type,
    required this.isActive,
    this.expiryDate,
    required this.trainingSessionsLimit,
    required this.trainingSessionsUsed,
  });

  Subscription copyWith({
    SubscriptionType? type,
    bool? isActive,
    DateTime? expiryDate,
    int? trainingSessionsLimit,
    int? trainingSessionsUsed,
  }) {
    return Subscription(
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      expiryDate: expiryDate ?? this.expiryDate,
      trainingSessionsLimit: trainingSessionsLimit ?? this.trainingSessionsLimit,
      trainingSessionsUsed: trainingSessionsUsed ?? this.trainingSessionsUsed,
    );
  }

  @override
  List<Object?> get props => [
    type,
    isActive,
    expiryDate,
    trainingSessionsLimit,
    trainingSessionsUsed,
  ];
}