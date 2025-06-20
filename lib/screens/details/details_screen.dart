import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_hub/screens/chat/chat_home.dart';
import 'package:farmers_hub/screens/manage_post/manage_post_screen.dart';
import 'package:farmers_hub/services/chat_service.dart';
import 'package:farmers_hub/services/firebase_service.dart';
import 'package:flutter/material.dart';

import 'package:farmers_hub/utils/constants.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsScreen extends StatefulWidget {
  final String postId;

  final bool didComeFromManagedPosts;

  const DetailsScreen({super.key, required this.postId, required this.didComeFromManagedPosts});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final firebaseService = FirebaseService();

  // A set to keep track of viewed post IDs for the current session
  static final Set<String> _sessionViewedPosts = {};

  @override
  void initState() {
    super.initState();
    _incrementViewCountIfFirstTime();
  }

  void _incrementViewCountIfFirstTime() {
    // Only increment view count if the post hasn't been viewed in this session.
    // .add() returns true if the value was added (i.e., it wasn't already in the set).
    if (_sessionViewedPosts.add(widget.postId)) {
      firebaseService.incrementViewCount(postId: widget.postId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: homebackgroundColor,
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        backgroundColor: onboardingColor,
        automaticallyImplyLeading: true,
        title: Text(
          "Details",
          // style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection(FirebaseService().postCollection)
                .doc(widget.postId)
                .snapshots(),
        builder: (context, postSnapshot) {
          if (postSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: onboardingColor));
          }

          if (postSnapshot.hasError || !postSnapshot.hasData || !postSnapshot.data!.exists) {
            return const Center(child: Text("Post not found or has been deleted."));
          }

          return FutureBuilder<Map<String, dynamic>?>(
            // future: firebaseService.getPostDetails(widget.postId),
            future: firebaseService.getPostAndSellerDetails(widget.postId),
            builder: (context, sellerSnapshot) {
              if (sellerSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: onboardingColor));
              }

              if (sellerSnapshot.hasError || !sellerSnapshot.hasData || sellerSnapshot.data == null) {
                return const Center(child: Text("Failed to load user data."));
              }

              // final postDetails = snapshot.data;
              final postDetails = sellerSnapshot.data!['post'];
              final sellerData = sellerSnapshot.data!['seller'];
              final sellerUsername = sellerData["username"];

              final currentUserId = firebaseService.currentUser?.uid;
              final List<dynamic> likedBy = postDetails['likedBy'] ?? [];
              final bool isLiked = currentUserId != null && likedBy.contains(currentUserId);

              return SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageSection(),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTitleAndActions(
                              title: postDetails["title"],
                              price: postDetails["price"].toString(),
                              location: postDetails["location"],
                              isLiked: isLiked,
                              onLike:
                                  () =>
                                      firebaseService.updatePostLikes(postId: widget.postId, like: !isLiked),
                            ),
                            const SizedBox(height: 8),

                            _buildEngagementStats(
                              likes: postDetails["likes"].toString(),
                              views: postDetails["views"].toString(),
                              dated:
                                  DateFormat(
                                    'MMMM d, yyyy',
                                  ).format(postDetails["createdAt"].toDate()).toString(),
                            ),
                            const SizedBox(height: 16),

                            // _buildSellerInfo(username: postDetails["username"]),
                            _buildSellerInfo(username: sellerUsername),
                            const SizedBox(height: 24),

                            _buildActionButtons(
                              context,
                              // username: postDetails["username"],
                              username: sellerUsername,
                              postUserId: postDetails["sellerId"],
                            ),
                            const SizedBox(height: 18),

                            _buildVerifiedSellerBadge(verifiedSeller: postDetails["verifiedSeller"]),
                            const SizedBox(height: 4),

                            _buildDetailsSection(
                              category: postDetails["category"],
                              gender: postDetails["gender"],
                              averageWeight: postDetails["averageWeight"].toString(),
                              age: postDetails["age"].toString(),
                              phoneNumber: "12321323",
                              details: postDetails["details"],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        // Placeholder for the image. Replace with Image.network or Image.asset
        Container(
          height: 250,
          child: Image.asset("images/backgrounds/cow_2.png", width: double.infinity, fit: BoxFit.cover),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('1/4', style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleAndActions({
    required String title,
    required String price,
    required Map location,
    required bool isLiked,
    required VoidCallback onLike,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const Text(
        //   'Healthy female cow along with her calf, available for sale.',
        //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        // ),
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "\$",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: onboardingColor),
                    ),
                    Text(
                      price,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: onboardingColor),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(location["city"], style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {
                    // Handle share action
                  },
                  color: Colors.grey[700],
                ),
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border_outlined,
                    color: isLiked ? Colors.red : Colors.grey[700],
                  ),
                  // icon: Icon(Icons.favorite, color: Colors.red), // For liked state
                  onPressed: onLike,
                  color: Colors.grey[700],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEngagementStats({required String likes, required String views, required String dated}) {
    return Row(
      children: [
        Icon(Icons.favorite, color: Colors.red[400], size: 16),
        const SizedBox(width: 4),

        Text(likes, style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(width: 16),

        Icon(Icons.visibility_outlined, color: Colors.grey[600], size: 16),
        const SizedBox(width: 4),

        Text(views, style: TextStyle(fontSize: 12, color: Colors.grey)),
        const Spacer(),

        Text(dated, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildSellerInfo({required String username}) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundColor: Colors.purple, // Color from the 'M'
          child: Text('M', style: TextStyle(fontSize: 24, color: Colors.white)),
        ),
        const SizedBox(width: 12),
        Text(username, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, {required String username, required String postUserId}) {
    return Column(
      children: [
        firebaseService.currentUser!.uid == postUserId
            ? widget.didComeFromManagedPosts
                ? Container()
                : Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.manage_accounts_outlined, color: Colors.white),
                        label: Text('Manage Posts', style: TextStyle(color: Colors.white)),
                        onPressed: () async {
                          // Handle Chat action

                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => ManagePostScreen()),
                            );
                            //     .then((_) {
                            //   setState(() {});
                            // });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: onboardingColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                )
            : Container(),

        SizedBox(height: 4),

        firebaseService.currentUser!.uid == postUserId
            ? Container()
            : Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                    label: Text(
                      firebaseService.currentUser?.displayName == username
                          ? "Can't chat with yourself"
                          : 'Chat',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed:
                        firebaseService.currentUser?.displayName == username
                            ? null
                            : () async {
                              // Handle Chat action

                              final ChatService _chatService = ChatService(user: firebaseService.currentUser);
                              final user = firebaseService.currentUser;

                              await _chatService.addUserForChat(username: username);

                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ChatHome(user: user)),
                                );
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: onboardingColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),

                SizedBox(width: 6),

                firebaseService.currentUser?.displayName == username
                    ? Container()
                    : Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                        label: Text('WhatsApp', style: TextStyle(color: Colors.white)),
                        onPressed: () async {
                          final String whatsapp = "+1-14821421408214";
                          final String whatsappURlAndroid = "whatsapp://send?phone=$whatsapp&text=${""}";
                          final String whatsappIoSURL = "https://wa.me/$whatsapp?text=${Uri.tryParse("AAA")}";

                          if (Platform.isIOS) {
                            if (await canLaunchUrl(Uri.parse(whatsappIoSURL))) {
                              await launchUrl(Uri.parse(whatsappIoSURL));
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(const SnackBar(content: Text("Whatsapp not installed")));
                              }
                            }
                          } else {
                            // Android
                            if (await canLaunchUrl(Uri.parse(whatsappURlAndroid))) {
                              await launchUrl(Uri.parse(whatsappURlAndroid));
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(const SnackBar(content: Text("Whatsapp not installed")));
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: onboardingColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                // const SizedBox(width: 10),
              ],
            ),
      ],
    );
  }

  Widget _buildVerifiedSellerBadge({required bool verifiedSeller}) {
    if (!verifiedSeller) {
      return Container();
    } else {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.yellow[700], borderRadius: BorderRadius.circular(8)),
          child: Text(
            'Verified Seller',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      );
    }
  }

  Widget _buildDetailsSection({
    required String category,
    required String gender,
    required String averageWeight,
    required String age,
    required String phoneNumber,
    required String details,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Category:', category),
        _buildDetailRow('Gender:', gender),
        _buildDetailRow('Average Weight (in kg):', averageWeight),
        _buildDetailRow('Age (in years):', age), // Note: unusual age
        _buildDetailRow('Phone Number:', phoneNumber),

        const SizedBox(height: 8),

        Text('Additional Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        // Add Text widget here if there is additional info text
        Text(details),
        // Text('Some additional details about the cow and calf...'),
      ],
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
