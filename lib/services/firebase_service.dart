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

  final userCollection = "users";
  final postCollection = "posts";

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
      await _firestore.collection(userCollection).doc(user.uid).set({
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
        "hasChats": [],
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
      final doc = await _firestore.collection(userCollection).doc(user.uid).get();
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
  Future<DocumentSnapshot?> getCurrentUserData() async {
    // Ensure there is a logged-in user.
    if (currentUser == null) return null;

    try {
      final userDoc = await _firestore.collection(userCollection).doc(currentUser!.uid).get();
      return userDoc;
    } catch (e) {
      return Future.error("Error fetching user data");
    }
  }

  Future<DocumentSnapshot?> getUserDataById({required String uid}) async {
    try {
      final userDoc = await _firestore.collection(userCollection).doc(uid).get();
      return userDoc;
    } catch (e) {
      return Future.error("Error fetching user data");
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (currentUser == null) return;

    try {
      await currentUser!.updateDisplayName(data["username"]);
      await _firestore.collection(userCollection).doc(currentUser!.uid).update(data);

      await currentUser!.reload();
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
    String? village,
    String? city,
    String? province,
    String? country,
    String? details,
    bool? featured,
  }) async {
    await _firestore.collection("livestock").doc().set({
      "sellerId": currentUser?.uid,
      // "username": currentUser?.displayName,
      "title": title,
      "category": category,
      "gender": gender,
      "averageWeight": averageWeight,
      "quantity": quantity,
      "age": age,
      "price": price,
      "currency": "USD",
      "likes": 0,
      "likedByYou": false,
      "views": 0,
      "featured": featured ?? false,
      "verifiedSeller": false,
      "location": {
        "city": city ?? "",
        "province": province ?? "",
        "country": country ?? "",
        "village": village ?? "",
      },
      "hasBeenSold": false,
      "details": details ?? "",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> markPostAsSold(String postId) async {
    try {
      // Make it so when the ad has been sold, the featured flag is also removed
      await _firestore.collection("livestock").doc(postId).update({"hasBeenSold": true, "featured": false});
    } catch (e) {}
  }

  Future<void> deletePostById(String postId) async {
    try {
      await _firestore.collection("livestock").doc(postId).delete();
    } catch (e) {}
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

  Future<List<QueryDocumentSnapshot>> getAllPostsByFeatured() async {
    try {
      final QuerySnapshot querySnapshot =
          await _firestore.collection("livestock").where("featured", isEqualTo: true).get();

      return querySnapshot.docs;
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getPostDetails(String postId) async {
    try {
      final DocumentSnapshot documentSnapshot = await _firestore.collection("livestock").doc(postId).get();

      return documentSnapshot.data() as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, dynamic>> getPostAndSellerDetails(String postId) async {
    try {
      // Step 1: Fetch the post details
      final Map<String, dynamic> postData = await getPostDetails(postId);

      if (postData.isNotEmpty) {
        final String sellerId = postData['sellerId'];

        // Step 2: Fetch the seller's data using the sellerId
        final DocumentSnapshot? sellerSnapshot = await getUserDataById(uid: sellerId);
        final Map<String, dynamic>? sellerData = sellerSnapshot?.data() as Map<String, dynamic>?;

        // Step 3: Return a combined map with both post and seller data
        return {
          'post': postData,
          'seller': sellerData,
        };
      } else {
        // Handle cases where post is empty or has no sellerId
        throw Exception("Post not found or seller ID is missing.");
      }
    } catch (e) {
      // Propagate the error to be caught by the FutureBuilder
      rethrow;
    }
  }

  // Future<void> updatePostLikes(int liked, String postId) async {
  //   try {
  //     final docRef = await _firestore.collection("livestock").doc(postId).update({
  //       "likedByYou":
  //       "likes": liked
  //     });
  //   } catch (e) {
  //     print("Error updating post: $e");
  //     // Optionally re-throw the error to handle it in the UI.
  //     throw AuthException('Failed to update post. Please try again.');
  //   }
  // }
}
