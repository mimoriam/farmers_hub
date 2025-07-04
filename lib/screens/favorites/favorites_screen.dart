import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_hub/screens/add_post/add_post_screen.dart';
import 'package:farmers_hub/screens/chat/chat_home.dart';
import 'package:farmers_hub/screens/details/details_screen.dart';
import 'package:farmers_hub/screens/profile/profile_screen.dart';
import 'package:farmers_hub/services/firebase_service.dart';
import 'package:flutter/material.dart';

import 'package:farmers_hub/utils/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart'; // ADD THIS IMPORT

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final firebaseService = FirebaseService();

  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: homebackgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: null,
        backgroundColor: onboardingColor,
        automaticallyImplyLeading: false,
        title: Text(
          "My Favorites",
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (context.mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AddPostScreen()));
          }
        },
        backgroundColor: onboardingColor,
        elevation: 0,
        shape: CircleBorder(),
        child: Icon(Icons.camera_alt_outlined, color: Colors.white, size: 24),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 70,
        // shape: const UpwardNotchedAndRoundedRectangle(topCornerRadius: 12),
        notchMargin: 10,
        color: Colors.white,
        elevation: 0,
        // Shadow for the BottomAppBar
        // clipBehavior: Clip.antiAlias,
        clipBehavior: Clip.none,

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          // Children are the navigation items
          children: <Widget>[
            GestureDetector(
              onTap: () {
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(semanticsLabel: 'Home Icon', "images/icons/home.svg"),
                  Text(
                    'Home',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: onboardingColor,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                final user = firebaseService.currentUser;

                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ChatHome(user: user)),
                  );
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(semanticsLabel: 'Chat Icon', "images/icons/chat.svg"),
                  Text(
                    'Chat',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: onboardingColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () {},
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    semanticsLabel: 'Favorites Icon',
                    "images/icons/favorites.svg",
                    // colorFilter: ColorFilter.mode(onboardingColor, BlendMode.),
                  ),
                  Text(
                    'Favorites',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: onboardingColor,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(semanticsLabel: 'Profile Icon', "images/icons/profile.svg"),
                  Text(
                    'Profile',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: onboardingColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: FormBuilderTextField(
                  name: "search",
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value ?? "";
                    });
                  },
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 13.69,
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                    ),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: GoogleFonts.poppins(
                      textStyle: TextStyle(fontSize: 13.69, fontWeight: FontWeight.w400, height: 1.43),
                      color: Colors.grey,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF999999)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFFC1EBCA)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFFC1EBCA)),
                    ),
                  ),
                ),
              ),
            ),
          ];
        },

        body: FutureBuilder<List<QueryDocumentSnapshot>>(
          future: firebaseService.getFavoritedPosts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // return const Center(child: CircularProgressIndicator(color: onboardingColor));
              return Skeletonizer(
                ignoreContainers: true,
                ignorePointers: true,
                child: Column(
                  children: [
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.image, size: 50),
                        title: Text("Favorite Post Title"),
                        subtitle: Text("Post details..."),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.image, size: 50),
                        title: Text("Favorite Post Title"),
                        subtitle: Text("Post details..."),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.hasError) {
              return const Center(child: Text("Error loading favorites."));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("You have no favorited posts yet!"));
            }

            final allPosts = snapshot.data!;
            final filteredPosts =
            _searchQuery.isEmpty
                ? allPosts
                : allPosts.where((post) {
              final title =
                  (post.data() as Map<String, dynamic>)['title']?.toString().toLowerCase() ?? '';
              return title.contains(_searchQuery.toLowerCase());
            }).toList();

            if (filteredPosts.isEmpty) {
              return const Center(child: Text("No favorites match your search."));
            }

            // final postData = snapshot.data!;

            return ListView.builder(
              // itemCount: postData.length,
              itemCount: filteredPosts.length,
              itemBuilder: (BuildContext context, int index) {
                // final post = postData[index].data() as Map<String, dynamic>;
                // final postId = postData[index].id;

                final post = filteredPosts[index].data() as Map<String, dynamic>;
                final postId = filteredPosts[index].id;

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: GestureDetector(
                      onTap: () {
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                  DetailsScreen(
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
                          borderRadius: BorderRadius.circular(10.0),
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: Colors.grey.withOpacity(0.2),
                          //     spreadRadius: 2,
                          //     blurRadius: 10,
                          //     offset: const Offset(0, 5),
                          //   ),
                          // ],
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
    final List<String> imageUrls = List<String>.from(post['imageUrls'] ?? []);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopSection(
          imageUrl: imageUrls.first,
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

  Widget _buildTopSection({
    required String imageUrl,
    required String price,
    required String category,
    required String year,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.network(imageUrl, width: 140, height: 90, fit: BoxFit.fill),
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
