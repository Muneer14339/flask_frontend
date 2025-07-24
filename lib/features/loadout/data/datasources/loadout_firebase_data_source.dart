// // lib/features/Loadout/data/datasources/Loadout_firebase_data_source.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:rt_tiltcant_accgyro/features/loadout/domain/usecases/delete_scope.dart';
// import '../models/rifle_model.dart';
// import '../models/ammunition_model.dart';
// import '../models/scope_model.dart';
// import '../models/maintenance_model.dart';
//
// abstract class LoadoutFirebaseDataSource {
//   // Streams for real-time updates
//   Stream<List<RifleModel>> getRiflesStream();
//   Stream<List<AmmunitionModel>> getAmmunitionStream();
//   Stream<List<ScopeModel>> getScopesStream();
//   Stream<List<MaintenanceModel>> getMaintenanceStream();
//
//   // CRUD operations
//   Future<void> addRifle(RifleModel rifle);
//   Future<void> addAmmunition(AmmunitionModel ammunition);
//   Future<void> addScope(ScopeModel scope);
//   Future<void> addMaintenance(MaintenanceModel maintenance);
//
//   Future<void> updateRifle(RifleModel rifle);
//   Future<void> updateAmmunition(AmmunitionModel ammunition);
//   Future<void> updateScope(ScopeModel scope);
//   Future<void> deleteAmmunition(String id);
//   Future<void> completeMaintenance(String id);
//   Future<void> deleteMaintenance(String id);
//   Future<void> deleteScope(String id);
//
//   Future<void> setActiveRifle(String rifleId);
//   Future<RifleModel?> getActiveRifle();
// }
//
// class LoadoutFirebaseDataSourceImpl implements LoadoutFirebaseDataSource {
//   final FirebaseFirestore firestore;
//   final FirebaseAuth firebaseAuth;
//
//   LoadoutFirebaseDataSourceImpl({
//     required this.firestore,
//     required this.firebaseAuth,
//   });
//
//   String get _userId {
//     final user = firebaseAuth.currentUser;
//     if (user == null) {
//       throw Exception('User not authenticated');
//     }
//     return user.uid;
//   }
//
//   // Collection references
//   CollectionReference get _riflesCollection =>
//       firestore.collection('users').doc(_userId).collection('rifles');
//
//   CollectionReference get _ammunitionCollection =>
//       firestore.collection('users').doc(_userId).collection('ammunition');
//
//   CollectionReference get _scopesCollection =>
//       firestore.collection('users').doc(_userId).collection('scopes');
//
//   CollectionReference get _maintenanceCollection =>
//       firestore.collection('users').doc(_userId).collection('maintenance');
//
//   @override
//   Stream<List<RifleModel>> getRiflesStream() {
//     return _riflesCollection.snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         return RifleModel.fromFirestore(data, doc.id);
//       }).toList();
//     });
//   }
//
//   @override
//   Stream<List<AmmunitionModel>> getAmmunitionStream() {
//     return _ammunitionCollection.snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         return AmmunitionModel.fromFirestore(data, doc.id);
//       }).toList();
//     });
//   }
//
//   @override
//   Stream<List<ScopeModel>> getScopesStream() {
//     return _scopesCollection.snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         return ScopeModel.fromFirestore(data, doc.id);
//       }).toList();
//     });
//   }
//
//   @override
//   Stream<List<MaintenanceModel>> getMaintenanceStream() {
//     return _maintenanceCollection.snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         return MaintenanceModel.fromFirestore(data, doc.id);
//       }).toList();
//     });
//   }
//
//   @override
//   Future<void> addRifle(RifleModel rifle) async {
//     try {
//       await _riflesCollection.doc(rifle.id).set(rifle.toFirestore());
//     } catch (e) {
//       throw Exception('Failed to add rifle: $e');
//     }
//   }
//
//   @override
//   Future<void> addAmmunition(AmmunitionModel ammunition) async {
//     try {
//       await _ammunitionCollection
//           .doc(ammunition.id)
//           .set(ammunition.toFirestore());
//     } catch (e) {
//       throw Exception('Failed to add ammunition: $e');
//     }
//   }
//
//   @override
//   Future<void> addScope(ScopeModel scope) async {
//     try {
//       await _scopesCollection.doc(scope.id).set(scope.toFirestore());
//     } catch (e) {
//       throw Exception('Failed to add scope: $e');
//     }
//   }
//
//   @override
//   Future<void> addMaintenance(MaintenanceModel maintenance) async {
//     try {
//       await _maintenanceCollection
//           .doc(maintenance.id)
//           .set(maintenance.toFirestore());
//     } catch (e) {
//       throw Exception('Failed to add maintenance: $e');
//     }
//   }
//
//   @override
//   Future<void> updateRifle(RifleModel rifle) async {
//     try {
//       await _riflesCollection.doc(rifle.id).update(rifle.toFirestore());
//     } catch (e) {
//       throw Exception('Failed to update rifle: $e');
//     }
//   }
//
//   @override
//   Future<void> updateAmmunition(AmmunitionModel ammunition) async {
//     try {
//       await _ammunitionCollection
//           .doc(ammunition.id)
//           .update(ammunition.toFirestore());
//     } catch (e) {
//       throw Exception('Failed to update ammunition: $e');
//     }
//   }
//
//   @override
//   Future<void> updateScope(ScopeModel scope) async {
//     try {
//       await _scopesCollection.doc(scope.id).update(scope.toFirestore());
//     } catch (e) {
//       throw Exception('Failed to update scope: $e');
//     }
//   }
//
//   @override
//   Future<void> deleteAmmunition(String id) async {
//     try {
//       await _ammunitionCollection.doc(id).delete();
//     } catch (e) {
//       throw Exception('Failed to delete ammunition: $e');
//     }
//   }
//
//   @override
//   Future<void> deleteMaintenance(String id) async {
//     try {
//       await _maintenanceCollection.doc(id).delete();
//     } catch (e) {
//       throw Exception('Failed to delete maintenance: $e');
//     }
//   }
//
//   @override
//   Future<void> deleteScope(String id) async {
//     try {
//       await _scopesCollection.doc(id).delete();
//     } catch (e) {
//       throw Exception('Failed to delete maintenance: $e');
//     }
//   }
//
//   @override
//   Future<void> completeMaintenance(String id) async {
//     try {
//       await _maintenanceCollection.doc(id).update({
//         'lastCompleted': FieldValue.serverTimestamp(),
//         'currentCount': 0,
//       });
//     } catch (e) {
//       throw Exception('Failed to complete maintenance: $e');
//     }
//   }
//
//   @override
//   Future<void> setActiveRifle(String rifleId) async {
//     try {
//       final batch = firestore.batch();
//
//       // Set all rifles to inactive
//       final riflesSnapshot = await _riflesCollection.get();
//       for (final doc in riflesSnapshot.docs) {
//         batch.update(doc.reference, {'isActive': false});
//       }
//
//       // Set selected rifle to active
//       batch.update(_riflesCollection.doc(rifleId), {'isActive': true});
//
//       await batch.commit();
//     } catch (e) {
//       throw Exception('Failed to set active rifle: $e');
//     }
//   }
//
//   @override
//   Future<RifleModel?> getActiveRifle() async {
//     try {
//       final snapshot = await _riflesCollection
//           .where('isActive', isEqualTo: true)
//           .limit(1)
//           .get();
//
//       if (snapshot.docs.isNotEmpty) {
//         final doc = snapshot.docs.first;
//         final data = doc.data() as Map<String, dynamic>;
//         return RifleModel.fromFirestore(data, doc.id);
//       }
//
//       return null;
//     } catch (e) {
//       throw Exception('Failed to get active rifle: $e');
//     }
//   }
// }
