import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final bool darkMode;
  final bool notificationsEnabled;
  final String units; // 'Imperial' or 'Metric'
  final bool pushNotifications;
  final bool emailNotifications;
  final bool trainingReminders;

  const AppSettings({
    required this.darkMode,
    required this.notificationsEnabled,
    required this.units,
    required this.pushNotifications,
    required this.emailNotifications,
    required this.trainingReminders,
  });

  AppSettings copyWith({
    bool? darkMode,
    bool? notificationsEnabled,
    String? units,
    bool? pushNotifications,
    bool? emailNotifications,
    bool? trainingReminders,
  }) {
    return AppSettings(
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      units: units ?? this.units,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      trainingReminders: trainingReminders ?? this.trainingReminders,
    );
  }

  @override
  List<Object?> get props => [
    darkMode,
    notificationsEnabled,
    units,
    pushNotifications,
    emailNotifications,
    trainingReminders,
  ];
}