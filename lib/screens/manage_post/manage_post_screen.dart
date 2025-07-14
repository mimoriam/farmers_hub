import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_hub/generated/i18n/app_localizations.dart';
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

  bool _showSoldPosts = false;

  String _searchQuery = "";

  int _selectedTabIndex = 0;

  /// Determines which Firebase query to run based on the selected tab.
  Future<List<QueryDocumentSnapshot<Object?>>> _getFutureForSelectedTab() {
    switch (_selectedTabIndex) {
      case 0:
        return firebaseService.getAllPostsByCurrentUser();
      case 1:
        return firebaseService.getSoldPostsByCurrentUser();
      case 2:
        // return firebaseService.getFavoritedPosts();
        // Instead of favorited posts, return posts that are pending approval:
        return firebaseService.getPendingPostsByCurrentUser();
      default:
        return firebaseService.getAllPostsByCurrentUser();
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
          AppLocalizations.of(context)!.managePosts,
          // style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
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
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 0, top: 10),
                    child: FormBuilderTextField(
                      name: "search",
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: 13.69,
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value ?? "";
                        });
                      },
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.search,
                        hintStyle: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: 13.69,
                            fontWeight: FontWeight.w400,
                            height: 1.43,
                          ),
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
                  _buildTabBar(),

                  FutureBuilder(
                    future: _getFutureForSelectedTab(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Skeletonizer(
                          ignoreContainers: true,
                          child: Column(
                            children: [
                              Card(
                                child: ListTile(
                                  leading: Icon(Icons.image, size: 50),
                                  title: Text(AppLocalizations.of(context)!.youPostTitle),
                                  subtitle: Text(AppLocalizations.of(context)!.yourPostDetails),
                                ),
                              ),

                              Card(
                                child: ListTile(
                                  leading: Icon(Icons.image, size: 50),
                                  title: Text(AppLocalizations.of(context)!.youPostTitle),
                                  subtitle: Text(AppLocalizations.of(context)!.yourPostDetails),
                                ),
                              ),

                              Card(
                                child: ListTile(
                                  leading: Icon(Icons.image, size: 50),
                                  title: Text(AppLocalizations.of(context)!.youPostTitle),
                                  subtitle: Text(AppLocalizations.of(context)!.yourPostDetails),
                                ),
                              ),

                              Card(
                                child: ListTile(
                                  leading: Icon(Icons.image, size: 50),
                                  title: Text(AppLocalizations.of(context)!.youPostTitle),
                                  subtitle: Text(AppLocalizations.of(context)!.yourPostDetails),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                        return Center(child: Text(AppLocalizations.of(context)!.failedToLoad));
                      }

                      final postData = snapshot.data;

                      if (postData!.isEmpty) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          width: MediaQuery.of(context).size.width * 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Icon(
                                  Icons.post_add_outlined,
                                  color: Colors.grey[700],
                                  size: 34.0,
                                ),
                              ),
                              const Text(
                                'Nothing to see here',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333A44),
                                ),
                              ),

                              const SizedBox(height: 6.0),

                              Text(
                                'Your posts will show here',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final filteredPosts = _searchQuery.isEmpty
                          ? postData
                          : postData.where((post) {
                              final title =
                                  (post.data() as Map<String, dynamic>)['title']
                                      ?.toString()
                                      .toLowerCase() ??
                                  '';
                              return title.contains(_searchQuery.toLowerCase());
                            }).toList();

                      if (filteredPosts.isEmpty) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(AppLocalizations.of(context)!.noPost),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: filteredPosts.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          final post = filteredPosts[index].data() as Map<String, dynamic>;
                          final postId = filteredPosts[index].id;
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
                                        builder: (context) => DetailsScreen(
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
                                    child: Column(
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
                                        const SizedBox(height: 4),
                                        _buildSoldButton(hasBeenSold: post["hasBeenSold"]),
                                        const SizedBox(height: 4),
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

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _buildTabItem(0, AppLocalizations.of(context)!.allPost),
          SizedBox(width: 10),
          _buildTabItem(1, AppLocalizations.of(context)!.sold),
          SizedBox(width: 10),
          _buildTabItem(2, "Pending"),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String title) {
    bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? onboardingColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[500],
                fontWeight: FontWeight.w600,
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
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.network(imageUrl, width: 140, height: 90, fit: BoxFit.fill),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                price,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
              ),

              const SizedBox(height: 8),
              _buildDetailRow(AppLocalizations.of(context)!.category + ':', category),

              const SizedBox(height: 4),
              _buildDetailRow(AppLocalizations.of(context)!.model, year),
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
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection({required Map location, required String likes, required String views}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildIconTextRow(Icons.location_on, location["city"]),
            const SizedBox(width: 8),
            _buildIconTextRow(
              Icons.favorite,
              "$likes " + AppLocalizations.of(context)!.likes,
              iconColor: Colors.red,
            ),
            const SizedBox(width: 12),
            _buildIconTextRow(
              Icons.visibility,
              "$views " + AppLocalizations.of(context)!.views,
              iconColor: Colors.green,
            ),
          ],
        ),
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

  Widget _buildSoldButton({required bool hasBeenSold}) {
    return MaterialButton(
      onPressed: () {},
      color: hasBeenSold ? onboardingColor : Colors.grey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),

            SizedBox(width: 4),

            Text(
              hasBeenSold ? "Sold" : "Un-Sold",
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
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
        _buildIconTextRow(Icons.access_time, formattedDate.toString()),
        !hasBeenSold
            ? Row(
                children: [
                  _buildActionButton(
                    Icons.delete_outline,
                    Colors.red,
                    action: "Delete",
                    postId: postId,
                  ),

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

  void _showDeleteConfirmationDialog(String postId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.priority_high_rounded, color: Colors.red, size: 40),
              ),
              SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.youSure,
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.sureForDeletePost,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.cancel_outlined, color: Colors.red),
                      label: Text(
                        AppLocalizations.of(context)!.cancel,
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.delete_outline, color: Colors.white),
                      label: Text(
                        AppLocalizations.of(context)!.delete,
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () async {
                        await firebaseService.deletePostById(postId);

                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }

                        if (mounted) {
                          setState(() {}); // Refresh the list
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
            _showDeleteConfirmationDialog(postId);
          }

          if (action == "Edit") {
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
