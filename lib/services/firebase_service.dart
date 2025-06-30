import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:farmers_hub/utils/auth_exceptions.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_image_compress/flutter_image_compress.dart';

enum currencyType { syria, usd, euro, lira }

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Stream for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  final userCollection = "users";
  final postCollection = "posts";

  Future<String?> uploadImage(File image) async {
    try {
      // 1. Get the original filename.
      String originalFileName = p.basename(image.path);

      // 2. Create a timestamp.
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // 3. Combine them for a unique and readable filename.
      String fileName = '${timestamp}_$originalFileName';

      // 4. Create a reference and upload the file.
      Reference ref = _storage.ref().child('posts/${_auth.currentUser!.uid}/$fileName');

      // Compress the image
      final Uint8List? compressedImage = await FlutterImageCompress.compressWithFile(
        image.absolute.path,
        quality: 60,
      );

      if (compressedImage == null) {
        return null;
      }

      // UploadTask uploadTask = ref.putFile(image);
      UploadTask uploadTask = ref.putData(compressedImage);
      TaskSnapshot snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String?> uploadProfileImage(File image) async {
    try {
      String fileName = 'profile_image_${_auth.currentUser!.uid}.jpg';
      Reference ref = _storage.ref().child('users/${_auth.currentUser!.uid}/profile/$fileName');

      final Uint8List? compressedImage = await FlutterImageCompress.compressWithFile(
        image.absolute.path,
        quality: 85, // You might want a slightly higher quality for profile pictures
      );

      if (compressedImage == null) {
        return null;
      }

      UploadTask uploadTask = ref.putData(compressedImage);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> deleteImageFromUrl(String imageUrl) async {
    if (imageUrl.isEmpty) return;

    try {
      // Get a reference to the file from the download URL
      Reference photoRef = _storage.refFromURL(imageUrl);
      // Delete the file
      await photoRef.delete();
      print('Successfully deleted image from storage: $imageUrl');
    } on FirebaseException catch (e) {
      // Log the error but don't crash the app if the file doesn't exist
      print('Error deleting image from storage: $e');
    }
  }

  Future<List<String>> uploadImages(List<File> images) async {
    List<String> imageUrls = [];

    for (File image in images) {
      String? imageUrl = await uploadImage(image); // Reusing the single upload logic

      if (imageUrl != null) {
        imageUrls.add(imageUrl);
      }
    }
    return imageUrls;
  }

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
      // final userDoc = await _firestore.collection(userCollection).doc(currentUser!.uid).get();
      // final existingData = userDoc.data();
      // final oldImageUrl = existingData?['profileImage'];
      //
      // // Delete the old image
      // if (data.containsKey("profileImage") && oldImageUrl != "default_pfp.jpg") {
      //   await deleteImageFromUrl(oldImageUrl);
      // }

      if (data.containsKey("username")) {
        await currentUser!.updateDisplayName(data["username"]);
      }
      if (data.containsKey("profileImage")) {
        await currentUser!.updatePhotoURL(data["profileImage"]);
      }
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
    required String? gender,
    required String averageWeight,
    required int quantity,
    required int? age,
    required int price,
    required String currency,
    required String city,
    required List<String> imageUrls,
    // required String imageUrl,
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
      // "imageUrl": imageUrl,
      "imageUrls": imageUrls,
      "hasBeenSold": false,
      "details": details ?? "",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> editPost({
    required String postId,
    required String title,
    required String category,
    required String? gender,
    required String averageWeight,
    required int quantity,
    required int? age,
    required int price,
    required String currency,
    required String city,
    required List<String> imageUrls,
    required bool hasBeenSold,
    String? village,
    String? province,
    String? country,
    String? details,
    bool? featured,
  }) async {
    final List<String> keywordsTitle = _generateKeywords(title);
    final List<String> keywordsCategory = _generateKeywords(category);

    // Note: createdAt, likes, views etc. are preserved by using update()
    await _firestore.collection(postCollection).doc(postId).update({
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
      "featured": featured ?? false,
      "verifiedSeller": false,
      "location": {
        "city": city,
        "province": province ?? "",
        "country": country ?? "",
        "village": village ?? "",
      },
      "imageUrls": imageUrls,
      "hasBeenSold": hasBeenSold,
      "details": details ?? "",
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
      // Get the post details to find the image URLs
      final postDetails = await getPostDetails(postId);
      final List<dynamic>? imageUrls = postDetails['imageUrls'];

      // Delete all images associated with the post from Firebase Storage
      if (imageUrls != null) {
        for (final imageUrl in imageUrls) {
          await deleteImageFromUrl(imageUrl);
        }
      }

      // Delete the post document from Firestore
      await _firestore.collection(postCollection).doc(postId).delete();
    } catch (e) {
      print("Error deleting post: $e");
    }
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
      // final QuerySnapshot querySnapshot =
      //     await _firestore.collection(postCollection).where("featured", isEqualTo: true).get();

      // Do not return posts marked as sold
      final QuerySnapshot querySnapshot =
          await _firestore
              .collection(postCollection)
              .where("featured", isEqualTo: true)
              .where("hasBeenSold", isEqualTo: false)
              .get();

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

  Future<List<QueryDocumentSnapshot>> searchPosts(
    String query, {
    bool isCategorySearch = false,
    bool descending = true,
  }) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      final String lowerCaseQuery = query.toLowerCase();
      QuerySnapshot querySnapshot;

      // DO NOT return posts that have been marked as sold
      if (isCategorySearch) {
        querySnapshot =
            await _firestore
                .collection(postCollection)
                .where('searchCategoryKeywords', arrayContains: lowerCaseQuery)
                .where('hasBeenSold', isEqualTo: false)
                .orderBy('createdAt', descending: descending)
                .get();
      } else {
        // Same as above
        querySnapshot =
            await _firestore
                .collection(postCollection)
                .where('searchTitleKeywords', arrayContains: lowerCaseQuery)
                .where('hasBeenSold', isEqualTo: false)
                .orderBy('createdAt', descending: descending)
                .get();
      }

      return querySnapshot.docs;
    } catch (e) {
      print("Error searching posts: $e");
      return [];
    }
  }

  Future<List<QueryDocumentSnapshot>> searchPostsByCity(String query, {bool descending = true}) async {
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
              .where('hasBeenSold', isEqualTo: false)
              .orderBy('createdAt', descending: descending)
              .get();

      return querySnapshot.docs;
    } catch (e) {
      print("Error searching posts for city: $e");
      return [];
    }
  }

  Future<String> getTipOfTheDay() async {
    try {
      final DocumentSnapshot tipDoc =
          await _firestore.collection("tip_of_the_day").doc("hxcf10ioz0RL0VPZXqeM").get();

      if (tipDoc.exists) {
        final data = tipDoc.data() as Map<String, dynamic>;
        return data['message'] ?? 'Default tip: Remember to water your plants!';
      }
      return 'Tip not found.';
    } catch (e) {
      print("Error fetching tip of the day: $e");
      return 'Could not load tip.';
    }
  }

  Future<List<QueryDocumentSnapshot>> searchPostsByVillage(String query, {bool descending = true}) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      // final String lowerCaseQuery = query.toLowerCase();
      QuerySnapshot querySnapshot;

      querySnapshot =
          await _firestore
              .collection(postCollection)
              .where('location.village', isEqualTo: query)
              .where('hasBeenSold', isEqualTo: false)
              .orderBy('createdAt', descending: descending)
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

  Future<List<QueryDocumentSnapshot>> getSoldPostsByCurrentUser() async {
    try {
      final QuerySnapshot querySnapshot =
          await _firestore
              .collection(postCollection)
              .where("sellerId", isEqualTo: currentUser?.uid)
              .where("hasBeenSold", isEqualTo: true)
              .get();

      return querySnapshot.docs;
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getBackgroundImages() async {
    try {
      final ListResult result = await _storage.ref().child('backgrounds').listAll();
      final List<String> imageUrls = [];
      for (final Reference ref in result.items) {
        final String downloadUrl = await ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }
      return imageUrls;
    } catch (e) {
      print("Error getting background images: $e");
      return [];
    }
  }

  /// Deletes the current user's account and all of their posts.
  Future<void> deleteUserAndPosts() async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        // 1. Delete the user's data from the "users" collection
        await _firestore.collection(userCollection).doc(user.uid).delete();

        // 2. Get all posts by the current user
        final userPosts = await getAllPostsByCurrentUser();

        // 3. Delete each post
        for (final post in userPosts) {
          await deletePostById(post.id);
        }

        // 4. Delete the user's account from Firebase Authentication
        await user.delete();
      } else {
        throw AuthException('No user is currently signed in.');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw AuthException(
          'This operation is sensitive and requires recent authentication. Please log in again before retrying this request.',
        );
      } else {
        throw AuthException('Error deleting user: ${e.message}');
      }
    } catch (e) {
      throw AuthException('An unexpected error occurred while deleting the user and their posts.');
    }
  }
}
