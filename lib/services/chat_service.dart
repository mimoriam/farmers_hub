import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final user;

  ChatService({required this.user});

  Future<List> getUsersIdForChat() async {
    final doc = await _firestore.collection("users").doc(uid).get();

    final userData = doc.data();

    return userData!["hasChats"];
  }

  Stream<List<Map<String, dynamic>>> getUsersStreamForChatBasedOnIds(List users) {
    // Firestore's 'whereIn' query cannot handle an empty list.
    // If the list is empty, we return a stream containing an empty list of users.
    if (users.isEmpty) {
      return Stream.value([]);
    }

    return _firestore.collection("users").where(FieldPath.documentId, whereIn: users).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();

        return user;
      }).toList();
    });
  }

  Future<void> addUserForChat({required String username}) async {
    final userDoc = await _firestore.collection("users").doc(uid).get();

    final user = userDoc.data();

    final secondUserDoc =
        await _firestore.collection("users").where("username", isEqualTo: username).limit(1).get();

    final secondUser = secondUserDoc.docs.first;

    // Update logged in user
    await _firestore.collection("users").doc(uid).update({
      // "hasChats": FieldValue.arrayUnion([username]),
      "hasChats": FieldValue.arrayUnion([secondUser.id]),
    });

    // Update other user

    await _firestore.collection("users").doc(secondUser.id).update({
      // "hasChats": FieldValue.arrayUnion([user!["username"]]),
      "hasChats": FieldValue.arrayUnion([uid]),
    });
  }

  Stream<QuerySnapshot> getLastMessage(String userId, otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();

    String chatRoomId = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .snapshots();
  }

  Stream<QuerySnapshot> getMessages(String userId, otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();

    String chatRoomId = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  Future<void> sendMessage(String receiverId, String receiverEmail, String senderEmail, var message) async {
    final String currentUserId = uid!;
    // final String currentUserEmail = user["email"];
    final Timestamp timestamp = Timestamp.now();

    var newMessage = {
      "senderId": currentUserId,
      "senderEmail": senderEmail,
      "receiverEmail": receiverEmail,
      "receiverId": receiverId,
      "message": message,
      "timestamp": timestamp,
      "readBy": [currentUserId],
    };

    List<String> ids = [currentUserId, receiverId];
    ids.sort();

    String chatRoomId = ids.join('_');
    print(chatRoomId);

    await _firestore.collection("chat_rooms").doc(chatRoomId).collection("messages").add(newMessage);
  }

  Future<void> markMessagesAsRead(String chatRoomId) async {
    final querySnapshot =
        await _firestore
            .collection("chat_rooms")
            .doc(chatRoomId)
            .collection("messages")
            .where('receiverId', isEqualTo: uid)
            .get();

    for (var doc in querySnapshot.docs) {
      // Add the current user's ID to the readBy list if it's not already there
      await doc.reference.update({
        'readBy': FieldValue.arrayUnion([uid]),
      });
    }
  }

  Stream<int> getUnreadMessageCount(String otherUserId) {
    List<String> ids = [uid!, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .where('receiverId', isEqualTo: uid)
        .where(
          'readBy',
          whereNotIn: [
            [uid],
          ],
        )
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.where((doc) {
                final data = doc.data();
                // Additional client-side check to ensure the user's ID is not in the readBy list
                return !(data['readBy'] as List).contains(uid);
              }).length,
        );
  }
}
