// // lib/features/auth/data/datasources/firebase_auth_datasource.dart
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../model/user_model.dart';
//
// abstract class FirebaseAuthDataSource {
//   Future<UserModel> signInWithGoogle();
//   Future<UserModel> login(String email, String password);
//   Future<UserModel> signUp(String fullName, String email, String password);
//   Future<bool> forgotPassword(String email);
//   Future<bool> verifyOtp(String otp);
//   Future<void> signOut();
//   Future<UserModel?> getCurrentUser();
// }
//
// class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
//   final FirebaseAuth _firebaseAuth;
//   final GoogleSignIn _googleSignIn;
//   final FirebaseFirestore _firestore;
//
//   FirebaseAuthDataSourceImpl({
//     required FirebaseAuth firebaseAuth,
//     required GoogleSignIn googleSignIn,
//     required FirebaseFirestore firestore,
//   }) : _firebaseAuth = firebaseAuth,
//         _googleSignIn = googleSignIn,
//         _firestore = firestore;
//
//   @override
//   Future<UserModel> signInWithGoogle() async {
//     try {
//       // Sign out from any previous sessions
//       await _googleSignIn.signOut();
//
//       // Trigger the Google authentication flow
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//
//       if (googleUser == null) {
//         throw Exception('Google sign-in was cancelled');
//       }
//
//       // Obtain the auth details from the request
//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//
//       // Create a new credential
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.idToken,
//         idToken: googleAuth.idToken,
//       );
//
//       // Sign in to Firebase with the Google credentials
//       final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
//       final User? firebaseUser = userCredential.user;
//
//       if (firebaseUser == null) {
//         throw Exception('Failed to sign in with Google');
//       }
//
//       // Create user model
//       final userModel = UserModel(
//         id: firebaseUser.uid,
//         fullName: firebaseUser.displayName ?? 'Unknown User',
//         email: firebaseUser.email ?? '',
//       );
//
//       // Check if user document exists in Firestore
//       final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
//
//       if (!userDoc.exists) {
//         // Create new user document
//         await _firestore.collection('users').doc(firebaseUser.uid).set({
//           'id': firebaseUser.uid,
//           'fullName': firebaseUser.displayName ?? 'Unknown User',
//           'email': firebaseUser.email ?? '',
//           'photoURL': firebaseUser.photoURL,
//           'createdAt': FieldValue.serverTimestamp(),
//           'lastSignIn': FieldValue.serverTimestamp(),
//           'signInMethod': 'google',
//         });
//       } else {
//         // Update last sign in
//         await _firestore.collection('users').doc(firebaseUser.uid).update({
//           'lastSignIn': FieldValue.serverTimestamp(),
//         });
//       }
//
//       return userModel;
//     } on FirebaseAuthException catch (e) {
//       throw Exception('Firebase Auth Error: ${e.message}');
//     } catch (e) {
//       throw Exception('Google Sign-in Error: $e');
//     }
//   }
//
//   @override
//   Future<UserModel> login(String email, String password) async {
//     try {
//       final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       final User? firebaseUser = userCredential.user;
//       if (firebaseUser == null) {
//         throw Exception('Login failed');
//       }
//
//       // Update last sign in
//       await _firestore.collection('users').doc(firebaseUser.uid).update({
//         'lastSignIn': FieldValue.serverTimestamp(),
//       });
//
//       return UserModel(
//         id: firebaseUser.uid,
//         fullName: firebaseUser.displayName ?? 'User',
//         email: firebaseUser.email ?? '',
//       );
//     } on FirebaseAuthException catch (e) {
//       throw Exception('Login Error: ${e.message}');
//     }
//   }
//
//   @override
//   Future<UserModel> signUp(String fullName, String email, String password) async {
//     try {
//       final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       final User? firebaseUser = userCredential.user;
//       if (firebaseUser == null) {
//         throw Exception('Sign up failed');
//       }
//
//       // Update display name
//       await firebaseUser.updateDisplayName(fullName);
//
//       // Create user document in Firestore
//       await _firestore.collection('users').doc(firebaseUser.uid).set({
//         'id': firebaseUser.uid,
//         'fullName': fullName,
//         'email': email,
//         'createdAt': FieldValue.serverTimestamp(),
//         'lastSignIn': FieldValue.serverTimestamp(),
//         'signInMethod': 'email',
//       });
//
//       return UserModel(
//         id: firebaseUser.uid,
//         fullName: fullName,
//         email: email,
//       );
//     } on FirebaseAuthException catch (e) {
//       throw Exception('Sign up Error: ${e.message}');
//     }
//   }
//
//   @override
//   Future<bool> forgotPassword(String email) async {
//     try {
//       await _firebaseAuth.sendPasswordResetEmail(email: email);
//       return true;
//     } on FirebaseAuthException catch (e) {
//       throw Exception('Password Reset Error: ${e.message}');
//     }
//   }
//
//   @override
//   Future<bool> verifyOtp(String otp) async {
//     // This would depend on your OTP implementation
//     // For now, returning true as placeholder
//     return true;
//   }
//
//   @override
//   Future<void> signOut() async {
//     try {
//       await Future.wait([
//         _firebaseAuth.signOut(),
//         _googleSignIn.signOut(),
//       ]);
//     } catch (e) {
//       throw Exception('Sign out Error: $e');
//     }
//   }
//
//   @override
//   Future<UserModel?> getCurrentUser() async {
//     try {
//       final User? firebaseUser = _firebaseAuth.currentUser;
//       if (firebaseUser == null) return null;
//
//       return UserModel(
//         id: firebaseUser.uid,
//         fullName: firebaseUser.displayName ?? 'User',
//         email: firebaseUser.email ?? '',
//       );
//     } catch (e) {
//       return null;
//     }
//   }
// }