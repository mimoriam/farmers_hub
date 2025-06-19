import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_hub/screens/details/details_screen.dart';
import 'package:farmers_hub/services/firebase_service.dart';
import 'package:flutter/material.dart';

import 'package:farmers_hub/utils/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
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
          "My Favorites",
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<QueryDocumentSnapshot>>(
          future: firebaseService.getFavoritedPosts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: onboardingColor));
            }

            if (snapshot.hasError) {
              return const Center(child: Text("Error loading favorites."));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("You have no favorited posts yet!"));
            }

            final postData = snapshot.data!;

            return ListView.builder(
              itemCount: postData.length,
              itemBuilder: (BuildContext context, int index) {
                final post = postData[index].data() as Map<String, dynamic>;
                final postId = postData[index].id;

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: GestureDetector(
                      onTap: () {
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsScreen(
                                postId: postId.toString(),
                                didComeFromManagedPosts: false,
                              ),
                            ),
                          ).then((_) => setState(() {}));
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildPostCard(post, postId),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post, String postId) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopSection(
          price: post["price"].toString(),
          category: post["category"],
          year: post["age"].toString(),
        ),
        const SizedBox(height: 12),
        _buildStatsSection(
          location: post["location"],
          likes: post["likes"].toString(),
          views: post["views"].toString(),
        ),
        const SizedBox(height: 12),
        _buildBottomSection(createdAt: post["createdAt"]),
      ],
    );
  }

  Widget _buildTopSection({required String price, required String category, required String year}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.asset('images/backgrounds/car_bg.png', fit: BoxFit.fill, width: 120, height: 80),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(price, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              _buildDetailRow('Category:', category),
              const SizedBox(height: 4),
              _buildDetailRow('Model:', year),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Row(
      children: [
        Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        const SizedBox(width: 3),
        Expanded(
          child: Text(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection({required Map location, required String likes, required String views}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIconTextRow(Icons.location_on, location["city"]),
        const SizedBox(width: 8),
        _buildIconTextRow(Icons.favorite, likes, iconColor: Colors.red),
        const SizedBox(width: 12),
        _buildIconTextRow(Icons.visibility, views, iconColor: Colors.green),
      ],
    );
  }

  Widget _buildIconTextRow(IconData icon, String text, {Color iconColor = Colors.black54}) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 16, color: Colors.black54)),
      ],
    );
  }

  Widget _buildBottomSection({required Timestamp createdAt}) {
    final String formattedDate = DateFormat('MMMM d, y').format(createdAt.toDate());
    return _buildIconTextRow(Icons.access_time, formattedDate.toString());
  }
}