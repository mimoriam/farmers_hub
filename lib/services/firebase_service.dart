import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:farmers_hub/utils/auth_exceptions.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum currencyType { syria, usd, euro, lira }

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

  // Helper function to generate keywords from a title
  List<String> _generateKeywords(String title) {
    final List<String> keywords = [];
    // Make sure to handle multiple spaces and remove empty strings
    final List<String> words = title.toLowerCase().split(' ').where((s) => s.isNotEmpty).toList();

    for (final word in words) {
      for (int i = 1; i <= word.length; i++) {
        keywords.add(word.substring(0, i));
      }
    }
    return keywords;
  }

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
    // required String address,
    // required String signUpMode,
  }) async {
    try {
      await _firestore.collection(userCollection).doc(user.uid).set({
        "createdAt": FieldValue.serverTimestamp(),
        "lastSeenAt": FieldValue.serverTimestamp(),
        "email": user.email,
        "id": user.uid,
        "isEmailVerified": user.emailVerified ? true : false,
        "isAdmin": false,
        "defaultCurrency": currencyType.usd.name.toLowerCase(),
        "phoneInfo": {
          "completeNumber": phone["completeNumber"],
          "countryCode": phone["countryCode"],
          "countryISOCode": phone["countryISOCode"],
          // "completeNumber": "",
        },
        "hasChats": [],
        "location": {"city": "", "province": ""},
        "profileImage": "default_pfp.jpg",
        "username": username,
      });

      await currentUser!.updateDisplayName(username);
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateCurrency(String currency) async {
    try {
      await _firestore.collection(userCollection).doc(currentUser!.uid).update({
        "defaultCurrency": currency.toLowerCase(),
      });
    } catch (e) {
      print("Error updating currency");
    }
  }

  Future<void> updateLastSeenAs() async {
    try {
      await _firestore.collection(userCollection).doc(currentUser!.uid).update({
        "lastSeenAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error updating Last Seen As");
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

  Future<DocumentSnapshot?> getUserDataByEmail({required String email}) async {
    try {
      final querySnapshot =
          await _firestore.collection(userCollection).where('email', isEqualTo: email).limit(1).get();

      return querySnapshot.docs.first;
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
    required String currency,
    required String city,
    String? village,
    String? province,
    String? country,
    String? details,
    bool? featured,
  }) async {
    final List<String> keywordsTitle = _generateKeywords(title);
    final List<String> keywordsCategory = _generateKeywords(category);

    await _firestore.collection(postCollection).doc().set({
      "sellerId": currentUser?.uid,
      // "username": currentUser?.displayName,
      "title": title,
      "searchTitleKeywords": keywordsTitle,
      "searchCategoryKeywords": keywordsCategory,
      "category": category,
      "gender": gender,
      "averageWeight": averageWeight,
      "quantity": quantity,
      "age": age,
      "price": price,
      "currency": currency,
      "likes": 0,
      "likedBy": [],
      "views": 0,
      "featured": featured ?? false,
      "verifiedSeller": false,
      "location": {
        "city": city,
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
      await _firestore.collection(postCollection).doc(postId).update({
        "hasBeenSold": true,
        "featured": false,
      });
    } catch (e) {}
  }

  Future<void> deletePostById(String postId) async {
    try {
      await _firestore.collection(postCollection).doc(postId).delete();
    } catch (e) {}
  }

  Future<List<QueryDocumentSnapshot>> getAllPostsByCurrentUser() async {
    try {
      final QuerySnapshot querySnapshot =
          await _firestore.collection(postCollection).where("sellerId", isEqualTo: currentUser?.uid).get();

      return querySnapshot.docs;
    } catch (e) {
      return [];
    }
  }

  Future<List<QueryDocumentSnapshot>> getAllPostsBySellerId(String sellerId) async {
    try {
      final QuerySnapshot querySnapshot =
      await _firestore.collection(postCollection).where("sellerId", isEqualTo: sellerId).get();

      return querySnapshot.docs;
    } catch (e) {
      return [];
    }
  }

  Future<List<QueryDocumentSnapshot>> getAllPostsByFeatured() async {
    try {
      final QuerySnapshot querySnapshot =
          await _firestore.collection(postCollection).where("featured", isEqualTo: true).get();

      return querySnapshot.docs;
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getPostDetails(String postId) async {
    try {
      final DocumentSnapshot documentSnapshot = await _firestore.collection(postCollection).doc(postId).get();

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
        return {'post': postData, 'seller': sellerData};
      } else {
        // Handle cases where post is empty or has no sellerId
        throw Exception("Post not found or seller ID is missing.");
      }
    } catch (e) {
      // Propagate the error to be caught by the FutureBuilder
      rethrow;
    }
  }

  Future<void> updatePostLikes({required String postId, required bool like}) async {
    final postRef = _firestore.collection(postCollection).doc(postId);
    final userId = currentUser!.uid;

    try {
      await _firestore.runTransaction((transaction) async {
        final postSnapshot = await transaction.get(postRef);
        if (!postSnapshot.exists) {
          throw Exception("Post does not exist!");
        }

        final postData = postSnapshot.data() as Map<String, dynamic>;
        final List<dynamic> likedBy = postData['likedBy'] ?? [];

        if (like) {
          // Like the post
          if (likedBy.contains(userId)) {
            return;
          }
          transaction.update(postRef, {
            'likes': FieldValue.increment(1),
            'likedBy': FieldValue.arrayUnion([userId]),
          });
        } else {
          // Unlike the post
          if (!likedBy.contains(userId)) {
            return;
          }
          transaction.update(postRef, {
            'likes': FieldValue.increment(-1),
            'likedBy': FieldValue.arrayRemove([userId]),
          });
        }
      });
    } catch (e) {}
  }

  Future<void> incrementViewCount({required String postId}) async {
    final postRef = _firestore.collection(postCollection).doc(postId);
    try {
      await postRef.update({'views': FieldValue.increment(1)});
    } catch (e) {
      print("Error incrementing view count: $e");
      // Don't throw an error to the user for this, as it's a background task.
    }
  }

  Future<List<QueryDocumentSnapshot>> searchPosts(String query, {bool isCategorySearch = false}) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      final String lowerCaseQuery = query.toLowerCase();
      QuerySnapshot querySnapshot;

      if (isCategorySearch) {
        querySnapshot =
            await _firestore
                .collection(postCollection)
                .where('searchCategoryKeywords', arrayContains: lowerCaseQuery)
                .get();
      } else {
        querySnapshot =
            await _firestore
                .collection(postCollection)
                .where('searchTitleKeywords', arrayContains: lowerCaseQuery)
                .get();
      }

      return querySnapshot.docs;
    } catch (e) {
      print("Error searching posts: $e");
      return [];
    }
  }

  Future<List<QueryDocumentSnapshot>> searchPostsByCity(String query) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      // final String lowerCaseQuery = query.toLowerCase();
      QuerySnapshot querySnapshot;

        querySnapshot =
        await _firestore
            .collection(postCollection)
            .where('location.city', isEqualTo: query)
            .get();

      return querySnapshot.docs;
    } catch (e) {
      print("Error searching posts for city: $e");
      return [];
    }
  }

  Future<List<QueryDocumentSnapshot>> getFavoritedPosts() async {
    try {
      final QuerySnapshot querySnapshot =
          await _firestore.collection(postCollection).where("likedBy", arrayContains: currentUser!.uid).get();

      return querySnapshot.docs;
    } catch (e) {
      print("Error fetching favorited posts: $e");
      return [];
    }
  }
}
