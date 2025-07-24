// import 'package:hive/hive.dart';
// import '../models/rifle_model.dart';
// import '../models/ammunition_model.dart';
// import '../models/scope_model.dart';
// import '../models/maintenance_model.dart';
//
// abstract class LoadoutLocalDataSource {
//   Future<List<RifleModel>> getRifles();
//   Future<List<AmmunitionModel>> getAmmunition();
//   Future<List<ScopeModel>> getScopes();
//   Future<List<MaintenanceModel>> getMaintenance();
//
//   Future<void> addRifle(RifleModel rifle);
//   Future<void> addAmmunition(AmmunitionModel ammunition);
//   Future<void> addScope(ScopeModel scope);
//   Future<void> addMaintenance(MaintenanceModel maintenance);
//
//   Future<void> updateRifle(RifleModel rifle);
//   Future<void> deleteAmmunition(String id);
//   Future<void> completeMaintenance(String id);
//
//   Future<void> setActiveRifle(String rifleId);
//   Future<RifleModel?> getActiveRifle();
// }
//
// class LoadoutLocalDataSourceImpl implements LoadoutLocalDataSource {
//   final Box<RifleModel> rifleBox;
//   final Box<AmmunitionModel> ammunitionBox;
//   final Box<ScopeModel> scopeBox;
//   final Box<MaintenanceModel> maintenanceBox;
//
//   LoadoutLocalDataSourceImpl({
//     required this.rifleBox,
//     required this.ammunitionBox,
//     required this.scopeBox,
//     required this.maintenanceBox,
//   });
//
//   @override
//   Future<List<RifleModel>> getRifles() async {
//     return rifleBox.values.toList();
//   }
//
//   @override
//   Future<List<AmmunitionModel>> getAmmunition() async {
//     return ammunitionBox.values.toList();
//   }
//
//   @override
//   Future<List<ScopeModel>> getScopes() async {
//     return scopeBox.values.toList();
//   }
//
//   @override
//   Future<List<MaintenanceModel>> getMaintenance() async {
//     return maintenanceBox.values.toList();
//   }
//
//   @override
//   Future<void> addRifle(RifleModel rifle) async {
//     await rifleBox.put(rifle.id, rifle);
//   }
//
//   @override
//   Future<void> addAmmunition(AmmunitionModel ammunition) async {
//     await ammunitionBox.put(ammunition.id, ammunition);
//   }
//
//   @override
//   Future<void> addScope(ScopeModel scope) async {
//     await scopeBox.put(scope.id, scope);
//   }
//
//   @override
//   Future<void> addMaintenance(MaintenanceModel maintenance) async {
//     await maintenanceBox.put(maintenance.id, maintenance);
//   }
//
//   @override
//   Future<void> updateRifle(RifleModel rifle) async {
//     await rifleBox.put(rifle.id, rifle);
//   }
//
//   @override
//   Future<void> deleteAmmunition(String id) async {
//     await ammunitionBox.delete(id);
//   }
//
//   @override
//   Future<void> completeMaintenance(String id) async {
//     final maintenance = maintenanceBox.get(id);
//     if (maintenance != null) {
//       maintenance.lastCompleted = DateTime.now();
//       maintenance.currentCount = 0;
//       await maintenanceBox.put(id, maintenance);
//     }
//   }
//
//   @override
//   Future<void> setActiveRifle(String rifleId) async {
//     // Set all rifles to inactive
//     for (final rifle in rifleBox.values) {
//       rifle.isActive = false;
//       await rifleBox.put(rifle.id, rifle);
//     }
//
//     // Set the selected rifle to active
//     final selectedRifle = rifleBox.get(rifleId);
//     if (selectedRifle != null) {
//       selectedRifle.isActive = true;
//       await rifleBox.put(rifleId, selectedRifle);
//     }
//   }
//
//   @override
//   Future<RifleModel?> getActiveRifle() async {
//     // First try to find an active rifle
//     try {
//       return rifleBox.values.firstWhere((rifle) => rifle.isActive);
//     } catch (e) {
//       // If no active rifle found, return the first rifle or null
//       return rifleBox.values.isNotEmpty ? rifleBox.values.first : null;
//     }
//   }
// }