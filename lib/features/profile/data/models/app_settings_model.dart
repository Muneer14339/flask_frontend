// import '../../domain/entities/app_settings.dart';
//
// class AppSettingsModel extends AppSettings {
//   const AppSettingsModel({
//     required super.darkMode,
//     required super.notificationsEnabled,
//     required super.units,
//     required super.pushNotifications,
//     required super.emailNotifications,
//     required super.trainingReminders,
//   });
//
//   factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
//     return AppSettingsModel(
//       darkMode: json['darkMode'] ?? false,
//       notificationsEnabled: json['notificationsEnabled'] ?? true,
//       units: json['units'] ?? 'Imperial',
//       pushNotifications: json['pushNotifications'] ?? true,
//       emailNotifications: json['emailNotifications'] ?? true,
//       trainingReminders: json['trainingReminders'] ?? true,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'darkMode': darkMode,
//       'notificationsEnabled': notificationsEnabled,
//       'units': units,
//       'pushNotifications': pushNotifications,
//       'emailNotifications': emailNotifications,
//       'trainingReminders': trainingReminders,
//     };
//   }
//
//   factory AppSettingsModel.fromEntity(AppSettings settings) {
//     return AppSettingsModel(
//       darkMode: settings.darkMode,
//       notificationsEnabled: settings.notificationsEnabled,
//       units: settings.units,
//       pushNotifications: settings.pushNotifications,
//       emailNotifications: settings.emailNotifications,
//       trainingReminders: settings.trainingReminders,
//     );
//   }
// }