// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/user_profile_model.dart';
// import '../models/app_settings_model.dart';
// import '../../core/error/exceptions.dart';
//
// abstract class ProfileLocalDataSource {
//   Future<UserProfileModel> getCachedUserProfile();
//   Future<void> cacheUserProfile(UserProfileModel profile);
//   Future<AppSettingsModel> getCachedAppSettings();
//   Future<void> cacheAppSettings(AppSettingsModel settings);
//   Future<void> clearCache();
// }
//
// const String CACHED_USER_PROFILE = 'CACHED_USER_PROFILE';
// const String CACHED_APP_SETTINGS = 'CACHED_APP_SETTINGS';
//
// class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
//   final SharedPreferences sharedPreferences;
//
//   ProfileLocalDataSourceImpl({required this.sharedPreferences});
//
//   @override
//   Future<UserProfileModel> getCachedUserProfile() {
//     final jsonString = sharedPreferences.getString(CACHED_USER_PROFILE);
//     if (jsonString != null) {
//       return Future.value(UserProfileModel.fromJson(json.decode(jsonString)));
//     } else {
//       throw CacheException();
//     }
//   }
//
//   @override
//   Future<void> cacheUserProfile(UserProfileModel profile) {
//     return sharedPreferences.setString(
//       CACHED_USER_PROFILE,
//       json.encode(profile.toJson()),
//     );
//   }
//
//   @override
//   Future<AppSettingsModel> getCachedAppSettings() {
//     final jsonString = sharedPreferences.getString(CACHED_APP_SETTINGS);
//     if (jsonString != null) {
//       return Future.value(AppSettingsModel.fromJson(json.decode(jsonString)));
//     } else {
//       throw CacheException();
//     }
//   }
//
//   @override
//   Future<void> cacheAppSettings(AppSettingsModel settings) {
//     return sharedPreferences.setString(
//       CACHED_APP_SETTINGS,
//       json.encode(settings.toJson()),
//     );
//   }
//
//   @override
//   Future<void> clearCache() async {
//     await sharedPreferences.remove(CACHED_USER_PROFILE);
//     await sharedPreferences.remove(CACHED_APP_SETTINGS);
//   }
// }