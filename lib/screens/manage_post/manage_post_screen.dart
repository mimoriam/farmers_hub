import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_hub/screens/details/details_screen.dart';
import 'package:farmers_hub/screens/edit_post_screen/edit_post_screen.dart';
import 'package:farmers_hub/services/firebase_service.dart';
import 'package:flutter/material.dart';

import 'package:farmers_hub/utils/constants.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ManagePostScreen extends StatefulWidget {
  const ManagePostScreen({super.key});

  @override
  State<ManagePostScreen> createState() => _ManagePostScreenState();
}

class _ManagePostScreenState extends State<ManagePostScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

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
          "Manage Posts",
          // style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),

      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: FormBuilder(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20, top: 20),
                    child: FormBuilderTextField(
                      name: "search",
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(fontSize: 13.69, fontWeight: FontWeight.w400, height: 1.43),
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
                        // suffixIcon: IconButton(
                        //   icon: const Icon(Icons.mic_none_outlined, color: onboardingColor),
                        //   onPressed: null,
                        // ),
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

                  FutureBuilder(
                    future: firebaseService.getAllPostsByCurrentUser(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // return const Center(child: CircularProgressIndicator(color: onboardingColor));
                        return Skeletonizer(
                          ignoreContainers: true,
                          child: Column(
                            children: [
                              Card(
                                child: ListTile(
                                  leading: Icon(Icons.image, size: 50),
                                  title: Text("Your Post Title"),
                                  subtitle: Text("Post details..."),
                                ),
                              ),

                              Card(
                                child: ListTile(
                                  leading: Icon(Icons.image, size: 50),
                                  title: Text("Your Post Title"),
                                  subtitle: Text("Post details..."),
                                ),
                              ),

                              Card(
                                child: ListTile(
                                  leading: Icon(Icons.image, size: 50),
                                  title: Text("Your Post Title"),
                                  subtitle: Text("Post details..."),
                                ),
                              ),

                              Card(
                                child: ListTile(
                                  leading: Icon(Icons.image, size: 50),
                                  title: Text("Your Post Title"),
                                  subtitle: Text("Post details..."),
                                ),
                              ),

                              Card(
                                child: ListTile(
                                  leading: Icon(Icons.image, size: 50),
                                  title: Text("Your Post Title"),
                                  subtitle: Text("Post details..."),
                                ),
                              ),

                              Card(
                                child: ListTile(
                                  leading: Icon(Icons.image, size: 50),
                                  title: Text("Your Post Title"),
                                  subtitle: Text("Post details..."),
                                ),
                              ),

                              Card(
                                child: ListTile(
                                  leading: Icon(Icons.image, size: 50),
                                  title: Text("Your Post Title"),
                                  subtitle: Text("Post details..."),
                                ),
                              ),

                              Card(
                                child: ListTile(
                                  leading: Icon(Icons.image, size: 50),
                                  title: Text("Your Post Title"),
                                  subtitle: Text("Post details..."),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                        return const Center(child: Text("Failed to load user data."));
                      }

                      final postData = snapshot.data;

                      if (postData!.isEmpty) {
                        return const Center(child: Text("User has no posts!"));
                      }

                      return ListView.builder(
                        itemCount: postData.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          final post = postData[index].data() as Map<String, dynamic>;
                          final postId = postData[index].id;

                          final List<String> imageUrls = List<String>.from(post['imageUrls'] ?? []);

                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, bottom: 10, right: 10),
                              child: GestureDetector(
                                onTap: () {
                                  if (context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => DetailsScreen(
                                              postId: postId.toString(),
                                              didComeFromManagedPosts: true,
                                            ),
                                      ),
                                    ).then((_) {
                                      if (mounted) {
                                        setState(() {});
                                      }
                                    });
                                  }
                                },
                                child: Container(
                                  // width: 350, // Set a fixed width for the card
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 10,
                                        offset: const Offset(0, 5), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min, // To make the column wrap its content
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Top Section: Image and Details
                                        _buildTopSection(
                                          imageUrl: imageUrls.first,
                                          price: post["price"].toString(),
                                          category: post["category"],
                                          year: post["age"].toString(),
                                        ),
                                        const SizedBox(height: 12),

                                        // Middle Section: Location, Likes, Views
                                        _buildStatsSection(
                                          location: post["location"],
                                          likes: post["likes"].toString(),
                                          views: post["views"].toString(),
                                        ),
                                        const SizedBox(height: 4),

                                        // Sold Button
                                        _buildSoldButton(hasBeenSold: post["hasBeenSold"]),
                                        const SizedBox(height: 4),

                                        // Bottom Section: Timestamp and Action Buttons
                                        _buildBottomSection(
                                          createdAt: post["createdAt"],
                                          postId: postId.toString(),
                                          hasBeenSold: post["hasBeenSold"],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
        // Car Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.network(
            imageUrl,
            width: 140,
            height: 90,
            fit: BoxFit.fill,
          ),
          // child: Image.asset('images/backgrounds/car_bg.png', fit: BoxFit.fill, width: 120, height: 80),
        ),
        const SizedBox(width: 14),
        // Car Details
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

  /// Builds the section for location, likes, and views.
  Widget _buildStatsSection({required Map location, required String likes, required String views}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildIconTextRow(Icons.location_on, location["city"]),
            const SizedBox(width: 8),
            _buildIconTextRow(Icons.favorite, "$likes likes", iconColor: Colors.red),
            const SizedBox(width: 12),
            _buildIconTextRow(Icons.visibility, "$views views", iconColor: Colors.green),
          ],
        ),
        // const SizedBox(width: 8),
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

  /// Builds the green "Sold" button.
  Widget _buildSoldButton({required bool hasBeenSold}) {
    return MaterialButton(
      onPressed: () {},
      color: hasBeenSold ? onboardingColor : Colors.grey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),

            SizedBox(width: 8),

            Text(hasBeenSold ? "Sold" : "Un-Sold", style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection({
    required Timestamp createdAt,
    required String postId,
    required bool hasBeenSold,
  }) {
    final String formattedDate = DateFormat('MMMM d, y').format(createdAt.toDate());
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Timestamp
        // _buildIconTextRow(Icons.access_time, '02 days Ago'),
        _buildIconTextRow(Icons.access_time, formattedDate.toString()),

        // Action buttons
        !hasBeenSold
            ? Row(
              children: [
                _buildActionButton(Icons.delete_outline, Colors.red, action: "Delete", postId: postId),

                const SizedBox(width: 14),

                _buildActionButton(
                  Icons.edit,
                  onboardingColor,
                  action: "Edit",
                  postId: postId,
                  hasBeenSold: hasBeenSold,
                ),
              ],
            )
            : Row(children: []),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    Color color, {
    required String action,
    required String postId,
    bool? hasBeenSold,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: () async {
          if (action == "Delete") {
            await firebaseService.deletePostById(postId);

            if (context.mounted) {
              setState(() {});
            }
          }

          if (action == "Edit") {
            // await firebaseService.markPostAsSold(postId);

            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditPostScreen(postId: postId)),
              ).then((_) {
                if (mounted) {
                  setState(() {});
                }
              });
            }
          }
        },
        padding: EdgeInsets.zero,
        splashRadius: 20,
      ),
    );
  }
}
