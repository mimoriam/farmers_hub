import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:farmers_hub/utils/auth_exceptions.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Email/Password Registration
  Future<UserCredential> registerWithEmail({required String email, required String password}) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException {
      throw AuthException('Registration failed. Please try again.');
    }
  }

  // Email/Password Login
  Future<UserCredential> loginWithEmail({required String email, required String password}) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException {
      throw AuthException('Login failed. Please try again.');
    }
  }

  // Social Login (Google)
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        // https://firebase.google.com/docs/auth/flutter/errors
        // TODO: Handle different auth providers
        print(e.message);
      }
      throw AuthException('Google Sign-In failed. Please try again.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    } catch (_) {
      throw AuthException('Sign-out failed. Please try again.');
    }
  }

  Future<void> saveUserDataOnRegister({
    required User user,
    required String username,
    // required Map<String, String> phone,
    // required String address,
    // required String signUpMode,
  }) async {
    try {
      await _firestore.collection("users").doc(user.uid).set({
        "createdAt": FieldValue.serverTimestamp(),
        "email": user.email,
        "id": user.uid,
        "isEmailVerified": user.emailVerified ? true : false,
        "isAdmin": false,
        "phoneInfo": {
          // "completeNumber": phone["completeNumber"],
          // "countryCode": phone["countryCode"],
          // "countryISOCode": phone["countryISOCode"],
          "completeNumber": "",
        },
        "location": {"city": "", "province": ""},
        "profileImage": "default_pfp.jpg",
        "username": username,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<bool> checkIfUserDataExistsForSocialLogin({required User user}) async {
    try {
      final doc = await _firestore.collection("users").doc(user.uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  Future<void> sendForgetPasswordEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
    }
  }

  // * PROFILE CRUD:
  // *

  Future<DocumentSnapshot?> getCurrentUserData() async {
    // Ensure there is a logged-in user.
    if (currentUser == null) return null;

    try {
      final userDoc = await _firestore.collection("users").doc(currentUser!.uid).get();
      return userDoc;
    } catch (e) {
      return Future.error("Error fetching user data");
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (currentUser == null) return;

    try {
      await _firestore.collection("users").doc(currentUser!.uid).update(data);
    } catch (e) {
      print("Error updating user profile: $e");
      // Optionally re-throw the error to handle it in the UI.
      throw AuthException('Failed to update profile. Please try again.');
    }
  }

  // * POST CRUD:
  Future<void> createPost({
    required String title,
    required String category,
    required String gender,
    required String averageWeight,
    required int quantity,
    required int age,
    required int price,
    required String city,
    required String province,
    required String country,
    String? details,
  }) async {
    await _firestore.collection("livestock").doc().set({
      "sellerId": currentUser?.uid,
      "username": currentUser?.displayName,
      "title": title,
      "category": category,
      "gender": gender,
      "averageWeight": averageWeight,
      "quantity": quantity,
      "age": age,
      "price": price,
      "likes": 0,
      "views": 0,
      "featured": false,
      "verifiedSeller": false,
      "location": {"city": city, "province": province, "country": country},
      "details": details ?? "",
    });
  }

  Future<List<QueryDocumentSnapshot>> getAllPostsByCurrentUser() async {
    try {
      final QuerySnapshot querySnapshot =
          await _firestore.collection("livestock").where("sellerId", isEqualTo: currentUser?.uid).get();

      return querySnapshot.docs;
    } catch (e) {
      return [];
    }
  }
}
