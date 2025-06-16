import 'package:farmers_hub/screens/chat/chat_home.dart';
import 'package:farmers_hub/services/firebase_service.dart';
import 'package:flutter/material.dart';

import 'package:farmers_hub/utils/constants.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DetailsScreen extends StatefulWidget {
  final String postId;

  const DetailsScreen({super.key, required this.postId});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final firebaseService = FirebaseService();

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

      body: FutureBuilder(
        future: firebaseService.getPostDetails(widget.postId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: onboardingColor));
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Failed to load user data."));
          }

          final postDetails = snapshot.data;

          print(postDetails!["likes"]);
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
                        ),
                        const SizedBox(height: 8),

                        _buildEngagementStats(
                          likes: postDetails["likes"].toString(),
                          views: postDetails["views"].toString(),
                          dated:
                              DateFormat('MMMM d, yyyy').format(postDetails["createdAt"].toDate()).toString(),
                        ),
                        const SizedBox(height: 16),

                        _buildSellerInfo(username: postDetails["username"]),
                        const SizedBox(height: 24),

                        _buildActionButtons(context, username: postDetails["username"]),
                        const SizedBox(height: 18),

                        _buildVerifiedSellerBadge(verifiedSeller: postDetails["verifiedSeller"]),
                        const SizedBox(height: 16),

                        _buildDetailsSection(
                          category: postDetails["category"],
                          gender: postDetails["gender"],
                          averageWeight: postDetails["averageWeight"],
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

  Widget _buildTitleAndActions({required String title, required String price, required Map location}) {
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
                Text(
                  price,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: onboardingColor),
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
                  icon: const Icon(Icons.favorite_border_outlined),
                  // icon: Icon(Icons.favorite, color: Colors.red), // For liked state
                  onPressed: () {
                    // Handle favorite action
                  },
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

  Widget _buildActionButtons(BuildContext context, {required String username}) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            label: Text(
              firebaseService.currentUser?.displayName == username ? "Can't chat with yourself" : 'Chat',
              style: TextStyle(color: Colors.white),
            ),
            onPressed:
                firebaseService.currentUser?.displayName == username
                    ? null
                    : () {
                      // Handle Chat action
                      final user = firebaseService.currentUser;
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
        // const SizedBox(width: 10),
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
