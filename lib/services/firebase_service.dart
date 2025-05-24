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
    required Map<String, String> phone,
    required String address,
    required String signUpMode,
  }) async {
    try {
      await _firestore.collection("users").doc(user.uid).set({
        "address": address,
        "createdAt": FieldValue.serverTimestamp(),
        "email": user.email,
        "id": user.uid,
        "isEmailVerified": user.emailVerified ? true : false,
        "is_admin": false,
        "phoneInfo": {
          "completeNumber": phone["completeNumber"],
          "countryCode": phone["countryCode"],
          "countryISOCode": phone["countryISOCode"],
        },
        "profileImage": "default_pfp.jpg",
        "signUpMode": signUpMode,
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
}
