// // lib/features/loadout/data/datasources/ballistic_firebase_data_source.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../models/ballistic_models.dart';
//
// abstract class BallisticFirebaseDataSource {
//   // DOPE Card operations
//   Future<void> saveDopeEntry(DopeEntryModel entry);
//   Future<List<DopeEntryModel>> getDopeEntries(String rifleId);
//   Future<void> deleteDopeEntry(String entryId);
//   Stream<List<DopeEntryModel>> getDopeEntriesStream(String rifleId);
//
//   // Zero tracking operations
//   Future<void> saveZeroEntry(ZeroEntryModel entry);
//   Future<List<ZeroEntryModel>> getZeroEntries(String rifleId);
//   Future<void> deleteZeroEntry(String entryId);
//   Stream<List<ZeroEntryModel>> getZeroEntriesStream(String rifleId);
//
//   // Chronograph data operations
//   Future<void> saveChronographData(ChronographDataModel data);
//   Future<List<ChronographDataModel>> getChronographData(String rifleId);
//   Future<void> deleteChronographData(String dataId);
//   Stream<List<ChronographDataModel>> getChronographDataStream(String rifleId);
//
//   // Ballistic calculation operations
//   Future<void> saveBallisticCalculation(BallisticCalculationModel calculation);
//   Future<List<BallisticCalculationModel>> getBallisticCalculations(String rifleId);
//   Future<void> deleteBallisticCalculation(String calculationId);
//   Stream<List<BallisticCalculationModel>> getBallisticCalculationsStream(String rifleId);
// }
//
// class BallisticFirebaseDataSourceImpl implements BallisticFirebaseDataSource {
//   final FirebaseFirestore firestore;
//   final FirebaseAuth firebaseAuth;
//
//   BallisticFirebaseDataSourceImpl({
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
//   CollectionReference get _dopeCollection =>
//       firestore.collection('users').doc(_userId).collection('dope_entries');
//
//   CollectionReference get _zeroCollection =>
//       firestore.collection('users').doc(_userId).collection('zero_entries');
//
//   CollectionReference get _chronographCollection =>
//       firestore.collection('users').doc(_userId).collection('chronograph_data');
//
//   CollectionReference get _ballisticCalculationCollection =>
//       firestore.collection('users').doc(_userId).collection('ballistic_calculations');
//
//   // DOPE Card operations
//   @override
//   Future<void> saveDopeEntry(DopeEntryModel entry) async {
//     try {
//       await _dopeCollection.doc(entry.id).set(entry.toFirestore());
//     } catch (e) {
//       throw Exception('Failed to save DOPE entry: $e');
//     }
//   }
//
//   @override
//   Future<List<DopeEntryModel>> getDopeEntries(String rifleId) async {
//     try {
//       // First get by rifleId only, then sort in memory
//       final snapshot = await _dopeCollection
//           .where('rifleId', isEqualTo: rifleId)
//           .get();
//
//       final entries = snapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         return DopeEntryModel.fromFirestore(data, doc.id);
//       }).toList();
//
//       // Sort by distance in memory
//       entries.sort((a, b) => a.distance.compareTo(b.distance));
//       return entries;
//     } catch (e) {
//       throw Exception('Failed to get DOPE entries: $e');
//     }
//   }
//
//   @override
//   Future<void> deleteDopeEntry(String entryId) async {
//     try {
//       await _dopeCollection.doc(entryId).delete();
//     } catch (e) {
//       throw Exception('Failed to delete DOPE entry: $e');
//     }
//   }
//
//   @override
//   Stream<List<DopeEntryModel>> getDopeEntriesStream(String rifleId) {
//     return _dopeCollection
//         .where('rifleId', isEqualTo: rifleId)
//         .snapshots()
//         .map((snapshot) {
//       final entries = snapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         return DopeEntryModel.fromFirestore(data, doc.id);
//       }).toList();
//
//       // Sort by distance in memory
//       entries.sort((a, b) => a.distance.compareTo(b.distance));
//       return entries;
//     });
//   }
//
//   // Zero tracking operations
//   @override
//   Future<void> saveZeroEntry(ZeroEntryModel entry) async {
//     try {
//       await _zeroCollection.doc(entry.id).set(entry.toFirestore());
//     } catch (e) {
//       throw Exception('Failed to save zero entry: $e');
//     }
//   }
//
//   @override
//   Future<List<ZeroEntryModel>> getZeroEntries(String rifleId) async {
//     try {
//       // First get by rifleId only, then sort in memory
//       final snapshot = await _zeroCollection
//           .where('rifleId', isEqualTo: rifleId)
//           .get();
//
//       final entries = snapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         return ZeroEntryModel.fromFirestore(data, doc.id);
//       }).toList();
//
//       // Sort by createdAt in memory (newest first)
//       entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
//       return entries;
//     } catch (e) {
//       throw Exception('Failed to get zero entries: $e');
//     }
//   }
//
//   @override
//   Future<void> deleteZeroEntry(String entryId) async {
//     try {
//       await _zeroCollection.doc(entryId).delete();
//     } catch (e) {
//       throw Exception('Failed to delete zero entry: $e');
//     }
//   }
//
//   @override
//   Stream<List<ZeroEntryModel>> getZeroEntriesStream(String rifleId) {
//     return _zeroCollection
//         .where('rifleId', isEqualTo: rifleId)
//         .snapshots()
//         .map((snapshot) {
//       final entries = snapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         return ZeroEntryModel.fromFirestore(data, doc.id);
//       }).toList();
//
//       // Sort by createdAt in memory (newest first)
//       entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
//       return entries;
//     });
//   }
//
//   // Chronograph data operations
//   @override
//   Future<void> saveChronographData(ChronographDataModel data) async {
//     try {
//       await _chronographCollection.doc(data.id).set(data.toFirestore());
//     } catch (e) {
//       throw Exception('Failed to save chronograph data: $e');
//     }
//   }
//
//   @override
//   Future<List<ChronographDataModel>> getChronographData(String rifleId) async {
//     try {
//       // First get by rifleId only, then sort in memory
//       final snapshot = await _chronographCollection
//           .where('rifleId', isEqualTo: rifleId)
//           .get();
//
//       final data = snapshot.docs.map((doc) {
//         final docData = doc.data() as Map<String, dynamic>;
//         return ChronographDataModel.fromFirestore(docData, doc.id);
//       }).toList();
//
//       // Sort by createdAt in memory (newest first)
//       data.sort((a, b) => b.createdAt.compareTo(a.createdAt));
//       return data;
//     } catch (e) {
//       throw Exception('Failed to get chronograph data: $e');
//     }
//   }
//
//   @override
//   Future<void> deleteChronographData(String dataId) async {
//     try {
//       await _chronographCollection.doc(dataId).delete();
//     } catch (e) {
//       throw Exception('Failed to delete chronograph data: $e');
//     }
//   }
//
//   @override
//   Stream<List<ChronographDataModel>> getChronographDataStream(String rifleId) {
//     return _chronographCollection
//         .where('rifleId', isEqualTo: rifleId)
//         .snapshots()
//         .map((snapshot) {
//       final data = snapshot.docs.map((doc) {
//         final docData = doc.data() as Map<String, dynamic>;
//         return ChronographDataModel.fromFirestore(docData, doc.id);
//       }).toList();
//
//       // Sort by createdAt in memory (newest first)
//       data.sort((a, b) => b.createdAt.compareTo(a.createdAt));
//       return data;
//     });
//   }
//
//   // Ballistic calculation operations
//   @override
//   Future<void> saveBallisticCalculation(BallisticCalculationModel calculation) async {
//     try {
//       await _ballisticCalculationCollection.doc(calculation.id).set(calculation.toFirestore());
//     } catch (e) {
//       throw Exception('Failed to save ballistic calculation: $e');
//     }
//   }
//
//   @override
//   Future<List<BallisticCalculationModel>> getBallisticCalculations(String rifleId) async {
//     try {
//       // First get by rifleId only, then sort in memory
//       final snapshot = await _ballisticCalculationCollection
//           .where('rifleId', isEqualTo: rifleId)
//           .get();
//
//       final calculations = snapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         return BallisticCalculationModel.fromFirestore(data, doc.id);
//       }).toList();
//
//       // Sort by createdAt in memory (newest first)
//       calculations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
//       return calculations;
//     } catch (e) {
//       throw Exception('Failed to get ballistic calculations: $e');
//     }
//   }
//
//   @override
//   Future<void> deleteBallisticCalculation(String calculationId) async {
//     try {
//       await _ballisticCalculationCollection.doc(calculationId).delete();
//     } catch (e) {
//       throw Exception('Failed to delete ballistic calculation: $e');
//     }
//   }
//
//   @override
//   Stream<List<BallisticCalculationModel>> getBallisticCalculationsStream(String rifleId) {
//     return _ballisticCalculationCollection
//         .where('rifleId', isEqualTo: rifleId)
//         .snapshots()
//         .map((snapshot) {
//       final calculations = snapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         return BallisticCalculationModel.fromFirestore(data, doc.id);
//       }).toList();
//
//       // Sort by createdAt in memory (newest first)
//       calculations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
//       return calculations;
//     });
//   }
// }