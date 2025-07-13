import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_hub/screens/chat/chat_home.dart';
import 'package:farmers_hub/screens/details/details_user_posts_screen.dart';
import 'package:farmers_hub/screens/manage_post/manage_post_screen.dart';
import 'package:farmers_hub/services/chat_service.dart';
import 'package:farmers_hub/services/firebase_service.dart';
import 'package:farmers_hub/utils/time_format.dart';
import 'package:flutter/material.dart';

import 'package:farmers_hub/utils/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tap_debouncer/tap_debouncer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:collection/collection.dart';

class FavoriteIconButton extends StatefulWidget {
  final String postId;
  final bool initialIsLiked;
  final FirebaseService firebaseService;

  const FavoriteIconButton({
    super.key,
    required this.postId,
    required this.initialIsLiked,
    required this.firebaseService,
  });

  @override
  State<FavoriteIconButton> createState() => _FavoriteIconButtonState();
}

class _FavoriteIconButtonState extends State<FavoriteIconButton> {
  late bool _isLiked;
  bool _isLiking = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.initialIsLiked;
  }

  // This ensures the button updates if the stream provides a new value
  @override
  void didUpdateWidget(FavoriteIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIsLiked != oldWidget.initialIsLiked) {
      setState(() {
        _isLiked = widget.initialIsLiked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If the button is processing a like, show a spinner
    if (_isLiking) {
      return Padding(
        padding: EdgeInsets.all(12.0),
        child: SizedBox(
          width: 24,
          height: 24,
          child: Skeletonizer(
            effect: ShimmerEffect(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!),
            // ignoreContainers: true,
            child: Icon(Icons.favorite_border_outlined),
          ),
        ),
      );
    }

    // Otherwise, show the appropriate heart icon
    return IconButton(
      icon: Icon(
        _isLiked ? Icons.favorite : Icons.favorite_border_outlined,
        color: _isLiked ? Colors.red : Colors.grey[700],
      ),
      onPressed: () async {
        // Prevent multiple clicks
        if (_isLiking) return;

        // 1. Immediately update the local UI optimistically and show spinner
        setState(() {
          _isLiking = true;
          _isLiked = !_isLiked;
        });

        // 2. Call Firebase in the background
        await widget.firebaseService.updatePostLikes(postId: widget.postId, like: _isLiked);

        // 3. Hide the spinner once the background task is done
        if (mounted) {
          setState(() {
            _isLiking = false;
          });
        }
      },
    );
  }
}

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

  int _currentCarouselPage = 0;
  Future<Map<String, dynamic>?>? _sellerDetailsFuture;

  @override
  void initState() {
    super.initState();
    _incrementViewCountIfFirstTime();

    _sellerDetailsFuture = firebaseService.getPostAndSellerDetails(widget.postId);
  }

  void _incrementViewCountIfFirstTime() {
    // Only increment view count if the post hasn't been viewed in this session.
    // .add() returns true if the value was added (i.e., it wasn't already in the set).
    if (_sessionViewedPosts.add(widget.postId)) {
      firebaseService.incrementViewCount(postId: widget.postId);
    }
  }

  // --- NEW FUNCTION TO HANDLE PHONE CALLS ---
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // Show an error message if the device can't handle the request
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Could not launch the dialer for $phoneNumber")));
      }
    }
  }

  Widget _buildDialogContent(BuildContext context) {
    // TODO: Add reporting feature
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: <Widget>[
          // The main content of the dialog
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // To make the card compact
              children: <Widget>[
                const Text(
                  'Report a violating ad',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12.0),
                const TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Enter your report here...',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    ),
                  ),
                ),
                const SizedBox(height: 14.0),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add report logic here
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: onboardingColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    ),
                    child: const Text('Report to admin'),
                  ),
                ),
              ],
            ),
          ),
          // The close button
          // Positioned(
          //   right: 0.0,
          //   top: 0.0,
          //   child: GestureDetector(
          //     onTap: () {
          //       Navigator.of(context).pop();
          //     },
          //     child: Container(
          //       padding: const EdgeInsets.all(4),
          //       decoration: BoxDecoration(
          //         color: Colors.grey.shade200,
          //         borderRadius: const BorderRadius.only(
          //           topRight: Radius.circular(16),
          //           bottomLeft: Radius.circular(12),
          //         ),
          //       ),
          //       child: const Icon(Icons.close, color: Colors.black54),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: homebackgroundColor,
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        backgroundColor: onboardingColor,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return _buildDialogContent(context);
                },
              );
            },
            icon: Icon(Icons.report),
            color: Colors.white,
          ),
        ],
        title: Text(
          "Details",
          // style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection(FirebaseService().postCollection)
            .doc(widget.postId)
            .snapshots(),
        builder: (context, postSnapshot) {
          if (postSnapshot.connectionState == ConnectionState.waiting) {
            // return const Center(child: CircularProgressIndicator(color: onboardingColor));
            return Container();
          }

          if (postSnapshot.hasError || !postSnapshot.hasData || !postSnapshot.data!.exists) {
            return const Center(child: Text("Post not found or has been deleted."));
          }

          final postDetails = postSnapshot.data!.data() as Map<String, dynamic>;
          final currentUserId = firebaseService.currentUser?.uid;

          // Initialize local state from the stream data
          // final List<dynamic> likedBy = postDetails['likedBy'] ?? [];
          // _isLiked ??= currentUserId != null && likedBy.contains(currentUserId);
          // _likeCount ??= postDetails['likes'] ?? 0;

          return FutureBuilder<Map<String, dynamic>?>(
            // future: firebaseService.getPostDetails(widget.postId),
            // future: firebaseService.getPostAndSellerDetails(widget.postId),
            future: _sellerDetailsFuture,
            builder: (context, sellerSnapshot) {
              if (sellerSnapshot.connectionState == ConnectionState.waiting) {
                // return const Center(child: CircularProgressIndicator(color: onboardingColor));
                return Skeletonizer(
                  effect: ShimmerEffect(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                  ),
                  ignoreContainers: true,
                  ignorePointers: true,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImageSection([]),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // _buildTitleAndActions2({}),
                              _buildTitleAndActions(
                                currency: "",
                                title: "",
                                price: "",
                                location: {"city": "Wew lad"},
                                isLiked: true,
                                isLiking: false,
                                onLike: () => firebaseService.updatePostLikes(
                                  postId: widget.postId,
                                  like: !true,
                                ),
                              ),
                              const SizedBox(height: 8),

                              _buildEngagementStats(
                                likes: "",
                                views: "",
                                dated: Timestamp.fromDate(DateTime.now()),
                                // dated:
                                //     DateFormat(
                                //       'MMMM d, yyyy',
                                //     ).format(postDetails["createdAt"].toDate()).toString(),
                              ),
                              const SizedBox(height: 16),

                              // _buildSellerInfo(username: postDetails["username"]),
                              _buildSellerInfo(username: "", sellerData: "", profileImage: ""),
                              const SizedBox(height: 24),

                              _buildActionButtons(
                                context,
                                // username: postDetails["username"],
                                username: "",
                                postUserId: "",
                                phoneNumber: "",
                              ),
                              const SizedBox(height: 18),

                              _buildVerifiedSellerBadge(verifiedSeller: false),
                              const SizedBox(height: 4),

                              _buildDetailsSection(
                                category: "",
                                gender: "",
                                averageWeight: "",
                                age: "",
                                quantity: "",
                                // phoneNumber: "12321323",
                                phoneNumber: "",
                                details: "",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (sellerSnapshot.hasError ||
                  !sellerSnapshot.hasData ||
                  sellerSnapshot.data == null) {
                return const Center(child: Text("Failed to load user data."));
              }

              // final postDetails = snapshot.data;
              final postDetails = sellerSnapshot.data!['post'];
              final sellerData = sellerSnapshot.data!['seller'];
              final sellerUsername = sellerData["username"];
              final sellerNumber = sellerData["phoneInfo"];
              final sellerImage = sellerData["profileImage"];

              final currentUserId = firebaseService.currentUser?.uid;
              final List<dynamic> likedBy = postDetails['likedBy'] ?? [];
              final bool isLiked = currentUserId != null && likedBy.contains(currentUserId);

              final List<String> imageUrls = List<String>.from(postDetails['imageUrls'] ?? []);

              return SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // _buildImageSection(),
                      _buildImageSection(imageUrls),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTitleAndActions2(postDetails),
                            // _buildTitleAndActions(
                            //   currency: postDetails["currency"].toString().toLowerCase(),
                            //   title: postDetails["title"],
                            //   price: postDetails["price"].toString(),
                            //   location: postDetails["location"],
                            //   // isLiked: isLiked,
                            //   // onLike:
                            //   //     () =>
                            //   //         firebaseService.updatePostLikes(postId: widget.postId, like: !isLiked),
                            //
                            //   // Use local state
                            //   isLiked: _isLiked!,
                            //
                            //   isLiking: _isLiking,
                            //
                            //   onLike: () async {
                            //     if (_isLiking) return; // Prevent multiple clicks
                            //
                            //     setState(() {
                            //       _isLiking = true; // Start loading
                            //       _isLiked = !_isLiked!;
                            //       if (_isLiked!) {
                            //         _likeCount = (_likeCount ?? 0) + 1;
                            //       } else {
                            //         _likeCount = (_likeCount ?? 0) - 1;
                            //       }
                            //     });
                            //
                            //     try {
                            //       await firebaseService.updatePostLikes(
                            //         postId: widget.postId,
                            //         like: _isLiked!,
                            //       );
                            //     } finally {
                            //       if (mounted) {
                            //         setState(() {
                            //           _isLiking = false; // Stop loading
                            //         });
                            //       }
                            //     }
                            //   },
                            // ),
                            const SizedBox(height: 8),

                            _buildEngagementStats(
                              likes: postDetails["likes"].toString(),

                              // Use local state for likes
                              // likes: _likeCount.toString(),
                              views: postDetails["views"].toString(),
                              dated: postDetails["createdAt"],
                              // dated:
                              //     DateFormat(
                              //       'MMMM d, yyyy',
                              //     ).format(postDetails["createdAt"].toDate()).toString(),
                            ),
                            const SizedBox(height: 16),

                            // _buildSellerInfo(username: postDetails["username"]),
                            _buildSellerInfo(
                              username: sellerUsername,
                              sellerData: sellerData,
                              profileImage: sellerImage,
                            ),
                            const SizedBox(height: 24),

                            _buildActionButtons(
                              context,
                              // username: postDetails["username"],
                              username: sellerUsername,
                              postUserId: postDetails["sellerId"],
                              phoneNumber: sellerNumber["completeNumber"],
                            ),
                            const SizedBox(height: 18),

                            _buildVerifiedSellerBadge(
                              verifiedSeller: postDetails["verifiedSeller"],
                            ),
                            const SizedBox(height: 4),

                            _buildDetailsSection(
                              category: postDetails["category"],
                              gender: postDetails["gender"],
                              averageWeight: postDetails["averageWeight"].toString(),
                              age: postDetails["age"].toString(),
                              quantity: postDetails["quantity"].toString(),
                              // phoneNumber: "12321323",
                              phoneNumber: sellerNumber["completeNumber"],
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

  // Widget _buildImageSection() {
  //   return Stack(
  //     children: [
  //       // Placeholder for the image. Replace with Image.network or Image.asset
  //       Container(
  //         height: 250,
  //         child: Image.asset("images/backgrounds/cow_2.png", width: double.infinity, fit: BoxFit.cover),
  //       ),
  //       Positioned(
  //         bottom: 10,
  //         right: 10,
  //         child: Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //           decoration: BoxDecoration(
  //             color: Colors.black.withOpacity(0.7),
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           child: const Text('1/4', style: TextStyle(color: Colors.white, fontSize: 12)),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildImageSection(List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[300],
        child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey[600]),
      );
    }

    // If there's only one image, just display it directly without the CarouselSlider
    if (imageUrls.length == 1) {
      return Image.network(
        imageUrls.first,
        height: 300, // Ensure consistent height
        fit: BoxFit.fill,
        width: double.infinity,
        // Add a loading builder and error builder for better UX
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 300,
            color: Colors.grey[300],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                color: onboardingColor, // Or your app's theme color
              ),
            ),
          );
        },
        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
          return Container(
            height: 300,
            color: Colors.grey[300],
            child: Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey[600])),
          );
        },
      );
    }

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Stack(
          children: [
            // CarouselSlider.builder(
            //   itemCount: imageUrls.length,
            //   itemBuilder: (context, index, realIndex) {
            //     final imageUrl = imageUrls[index];
            //     return Image.network(imageUrl, fit: BoxFit.fill, width: double.infinity);
            //   },
            CarouselSlider(
              items: imageUrls.mapIndexed((index, element) {
                final imageUrl = imageUrls[index];
                return Builder(
                  builder: (BuildContext context) {
                    return Image.network(imageUrl, fit: BoxFit.fill, width: double.infinity);
                  },
                );
              }).toList(),
              options: CarouselOptions(
                height: 300,
                viewportFraction: 1.0,
                enlargeCenterPage: false,
                enlargeFactor: 1,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentCarouselPage = index;
                  });
                },
              ),
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
                child: Text(
                  '${_currentCarouselPage + 1}/${imageUrls.length}',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            // if (imageUrls.length > 1)
            //   Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children:
            //         imageUrls.asMap().entries.map((entry) {
            //           return Container(
            //             width: 8.0,
            //             height: 8.0,
            //             margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
            //             decoration: BoxDecoration(
            //               shape: BoxShape.circle,
            //               color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)
            //                   .withOpacity(_currentCarouselPage == entry.key ? 0.9 : 0.4),
            //             ),
            //           );
            //         }).toList(),
            //   ),
          ],
        );
      },
    );
  }

  Widget _buildTitleAndActions2(Map<String, dynamic> postDetails) {
    final String currency = postDetails["currency"].toString().toLowerCase();
    final String title = postDetails["title"];
    final String price = postDetails["price"].toString();
    final Map location = postDetails["location"];
    final currentUserId = firebaseService.currentUser?.uid;
    final List<dynamic> likedBy = postDetails['likedBy'] ?? [];
    final bool isCurrentlyLiked = currentUserId != null && likedBy.contains(currentUserId);
    final String village = postDetails["location"]["village"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
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
                      currency == "usd"
                          ? "\$"
                          : currency == "euro"
                          ? "€"
                          : currency == "lira"
                          ? "₺"
                          : "(SYP)",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: onboardingColor,
                      ),
                    ),
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: onboardingColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(location["city"], style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    Text(", "),
                    Text(village, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {},
                  color: Colors.grey[700],
                ),
                // USE THE NEW WIDGET HERE
                FavoriteIconButton(
                  postId: widget.postId,
                  initialIsLiked: isCurrentlyLiked,
                  firebaseService: firebaseService,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitleAndActions({
    required String currency,
    required String title,
    required String price,
    required Map location,
    required bool isLiked,
    required bool isLiking,
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
                      currency == "usd"
                          ? "\$"
                          : currency == "euro"
                          ? "€"
                          : currency == "lira"
                          ? "₺"
                          : "(SYP)",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: onboardingColor,
                      ),
                    ),
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: onboardingColor,
                      ),
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

                isLiking
                    ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.grey[700],
                          ),
                        ),
                      )
                    : IconButton(
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

  Widget _buildEngagementStats({
    required String likes,
    required String views,
    required Timestamp dated,
  }) {
    final currentUserId = firebaseService.currentUser?.uid;
    final postedAgoText = formatTimeAgo(dated);

    // CHANGED this from Row to Column
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: Colors.red[400], size: 16),
                const SizedBox(width: 4),

                Text("Likes:", style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(width: 1),
                Text(likes, style: TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),

            const SizedBox(width: 12),

            Row(
              children: [
                Icon(Icons.visibility_outlined, color: Colors.grey[600], size: 16),
                const SizedBox(width: 4),

                Text("Views:", style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(width: 1),
                Text(views, style: TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ],
        ),

        const SizedBox(height: 8),

        // const Spacer(),
        Row(
          children: [
            Icon(Icons.history_outlined, color: Colors.grey[600], size: 16),
            const SizedBox(width: 4),

            Text(postedAgoText.toString(), style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }

  Widget _buildSellerInfo({
    required String profileImage,
    required String username,
    required sellerData,
  }) {
    return GestureDetector(
      onTap: () {
        // TODO: Check User's profile posts
        // if (context.mounted) {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => DetailsUserPostsScreen(postSellerData: sellerData),
        //     ),
        //   );
        // }
      },
      child: Row(
        children: [
          profileImage == "default_pfp.jpg" || profileImage == ""
              ? CircleAvatar(
                  radius: 24,
                  backgroundColor: onboardingColor, // Color from the 'M'
                  child: Text('A', style: TextStyle(fontSize: 24, color: Colors.white)),
                )
              : CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(profileImage), // Use NetworkImage for URLs
                  // Or AssetImage for local assets: AssetImage('assets/your_image.png')
                ),
          const SizedBox(width: 12),
          Text(username, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context, {
    required String username,
    required String postUserId,
    required String phoneNumber,
  }) {
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
                  SizedBox(width: 3),
                  TapDebouncer(
                    cooldown: const Duration(milliseconds: 2000),
                    onTap: firebaseService.currentUser?.displayName == username
                        ? null
                        : () async {
                            // Handle Chat action

                            final ChatService _chatService = ChatService(
                              user: firebaseService.currentUser,
                            );
                            final user = firebaseService.currentUser;

                            await _chatService.addUserForChat(username: username);

                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ChatHome(user: user)),
                              );
                            }
                          },
                    builder: (BuildContext context, TapDebouncerFunc? onTap) {
                      return Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                          label: Text(
                            firebaseService.currentUser?.displayName == username
                                ? "Can't chat with yourself"
                                : 'Chat',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: onboardingColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(width: 10),

                  firebaseService.currentUser?.displayName == username
                      ? Container()
                      : Expanded(
                          child: ElevatedButton.icon(
                            // icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                            icon: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
                            label: Text('WhatsApp', style: TextStyle(color: Colors.white)),
                            onPressed: () async {
                              // final String whatsapp = "+1-14821421408214";
                              final String whatsapp = phoneNumber;
                              final String whatsappURlAndroid =
                                  "whatsapp://send?phone=$whatsapp&text=${""}";
                              final String whatsappIoSURL =
                                  "https://wa.me/$whatsapp?text=${Uri.tryParse("AAA")}";

                              if (Platform.isIOS) {
                                if (await canLaunchUrl(Uri.parse(whatsappIoSURL))) {
                                  await launchUrl(Uri.parse(whatsappIoSURL));
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Whatsapp not installed")),
                                    );
                                  }
                                }
                              } else {
                                // Android
                                if (await canLaunchUrl(Uri.parse(whatsappURlAndroid))) {
                                  await launchUrl(Uri.parse(whatsappURlAndroid));
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Whatsapp not installed")),
                                    );
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
          decoration: BoxDecoration(
            color: Colors.yellow[700],
            borderRadius: BorderRadius.circular(8),
          ),
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
    required String quantity,
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

        _buildDetailRow('Quantity:', quantity),

        category == "Fruits" ||
                category == "Vegetables" ||
                category == "Olive Oil" ||
                category == "Grains & Seeds" ||
                category == "Fertilizers" ||
                category == "Tools" ||
                category == "Land Services" ||
                category == "Equipments" ||
                category == "Delivery" ||
                category == "Pesticides" ||
                category == "Animal Feed" ||
                category == "Others"
            ? Container()
            : _buildDetailRow('Gender:', gender),

        (averageWeight.isNotEmpty)
            ? _buildDetailRow('Average Weight (in kg):', averageWeight)
            : Container(),

        category == "Fruits" ||
                category == "Vegetables" ||
                category == "Olive Oil" ||
                category == "Grains & Seeds" ||
                category == "Fertilizers" ||
                category == "Tools" ||
                category == "Land Services" ||
                category == "Equipments" ||
                category == "Delivery" ||
                category == "Pesticides" ||
                category == "Animal Feed" ||
                category == "Others"
            ? Container()
            : _buildDetailRow('Age (in years):', age), // Note: unusual age

        _buildDetailRow('Phone Number:', phoneNumber, phoneBlue: true),

        const SizedBox(height: 8),

        Text('Additional Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        // Add Text widget here if there is additional info text
        Text(details),
        // Text('Some additional details about the cow and calf...'),
      ],
    );
  }

  Widget _buildDetailRow(String title, String value, {bool? phoneBlue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 15, color: Colors.grey[700])),
          GestureDetector(
            onTap: phoneBlue == true
                ? () {
                    _makePhoneCall(value);
                  }
                : null,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: phoneBlue == true ? Colors.blue : null,
                decoration: phoneBlue == true ? TextDecoration.underline : null,
                decorationColor: phoneBlue == true ? Colors.blue : null,
                decorationThickness: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
