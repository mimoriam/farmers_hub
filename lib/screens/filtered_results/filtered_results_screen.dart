import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_hub/services/firebase_service.dart';
import 'package:farmers_hub/utils/time_format.dart';
import 'package:flutter/material.dart';

import 'package:farmers_hub/utils/constants.dart';

import 'package:farmers_hub/screens/details/details_screen.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_fonts/google_fonts.dart';

class FilteredResultsScreen extends StatefulWidget {
  String searchQuery;

  FilteredResultsScreen({super.key, this.searchQuery = ""});

  @override
  State<FilteredResultsScreen> createState() => _FilteredResultsScreenState();
}

enum SearchOption { title, category }

// Enum for sort options
enum SortOption { ascending, descending }

class _FilteredResultsScreenState extends State<FilteredResultsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final validateMode = AutovalidateMode.onUserInteraction;

  final FirebaseService firebaseService = FirebaseService();

  List<QueryDocumentSnapshot> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  Timer? _debounce;

  SearchOption _selectedChip = SearchOption.title;

  Future<void> _performSearch(String query) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    var results;

    if (_selectedSearchOption == SearchOption.title) {
      results = await firebaseService.searchPosts(query);
    } else if (_selectedSearchOption == SearchOption.category) {
      results = await firebaseService.searchPosts(query, isCategorySearch: true);
    }

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String? query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query != null && query.isNotEmpty) {
        await _performSearch(query);
      } else if (mounted) {
        setState(() {
          _searchResults = [];
          _hasSearched = false; // Reset to initial state if search is cleared
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // If the screen is opened with an initial search query, perform the search
    if (widget.searchQuery.isNotEmpty) {
      _performSearch(widget.searchQuery);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  SearchOption _selectedSearchOption = SearchOption.title;
  SortOption _selectedSortOption = SortOption.ascending;

  void _showOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Use a StatefulWidget to manage the state within the dialog
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: scaffoldBackgroundColor,
              // title: const Text('Search & Sort Options'),
              content: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('Search by:', style: TextStyle(fontWeight: FontWeight.bold)),

                  RadioListTile<SearchOption>(
                    title: const Text('Title'),
                    value: SearchOption.title,
                    groupValue: _selectedSearchOption,
                    activeColor: onboardingColor,
                    onChanged: (SearchOption? value) {
                      setState(() {
                        if (mounted) {
                          _selectedSearchOption = value!;
                        }
                      });
                    },
                  ),

                  RadioListTile<SearchOption>(
                    title: const Text('Category'),
                    value: SearchOption.category,
                    groupValue: _selectedSearchOption,
                    activeColor: onboardingColor,
                    onChanged: (SearchOption? value) {
                      setState(() {
                        if (mounted) {
                          _selectedSearchOption = value!;
                        }
                      });
                    },
                  ),

                  // // const Divider(),
                  // const Text('Sort by:', style: TextStyle(fontWeight: FontWeight.bold)),
                  //
                  // RadioListTile<SortOption>(
                  //   title: const Text('Ascending'),
                  //   value: SortOption.ascending,
                  //   groupValue: _selectedSortOption,
                  //   activeColor: onboardingColor,
                  //   onChanged: (SortOption? value) {
                  //     setState(() {
                  //       if (mounted) {
                  //         _selectedSortOption = value!;
                  //       }
                  //     });
                  //   },
                  // ),
                  //
                  // RadioListTile<SortOption>(
                  //   title: const Text('Descending'),
                  //   value: SortOption.descending,
                  //   groupValue: _selectedSortOption,
                  //   activeColor: onboardingColor,
                  //   onChanged: (SortOption? value) {
                  //     setState(() {
                  //       if (mounted) {
                  //         _selectedSortOption = value!;
                  //       }
                  //     });
                  //   },
                  // ),
                ],
              ),
              // actions: <Widget>[
              //   TextButton(
              //     child: const Text('Done'),
              //     onPressed: () {
              //       Navigator.of(context).pop();
              //     },
              //   ),
              // ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> popularPostsData = const [
      {
        "image_url": "images/backgrounds/cow_2.png",
        "price": "330,000",
        "location": "Mirpur Mathelo",
        "likes": 12,
        "posted_ago": "02 Months Ago",
        "views": 301,
      },

      {
        "image_url": "images/backgrounds/goat.png",
        "price": "330,000",
        "location": "Mirpur Mathelo",
        "likes": 0,
        "posted_ago": "02 Months Ago",
        "views": 274,
      },

      {
        "image_url": "images/backgrounds/fertilizers_spray.jpg",
        "price": "330,000",
        "location": "Mirpur Mathelo",
        "likes": 4,
        "posted_ago": "02 Months Ago",
        "views": 274,
      },

      {
        "image_url": "images/backgrounds/man_with_stick.png",
        "price": "430,000",
        "location": "Mirpur Mathelo",
        "likes": 12,
        "posted_ago": "02 Months Ago",
        "views": 301,
      },

      {
        "image_url": "images/backgrounds/tools_and_equipments_bg.jpg",
        "price": "430,000",
        "location": "Mirpur Mathelo",
        "likes": 48,
        "posted_ago": "02 Months Ago",
        "views": 521,
      },

      {
        "image_url": "images/backgrounds/bull_and_cow.png",
        "price": "430,000",
        "location": "Mirpur Mathelo",
        "likes": 48,
        "posted_ago": "02 Months Ago",
        "views": 221,
      },
    ];

    bool selectedTitle = true;

    return Scaffold(
      backgroundColor: homebackgroundColor,
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        backgroundColor: onboardingColor,
        automaticallyImplyLeading: true,
        title: Text(
          "Filtered Search Result",
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 6, top: 14),
                    child: FormBuilderTextField(
                      name: "search",
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(fontSize: 13.69, fontWeight: FontWeight.w400, height: 1.43),
                      ),
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: GoogleFonts.poppins(
                          textStyle: TextStyle(fontSize: 13.69, fontWeight: FontWeight.w400, height: 1.43),
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF999999)),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.mic_none_outlined, color: onboardingColor),
                          // icon: const Icon(Icons.sort_outlined, color: onboardingColor),
                          onPressed: () {},
                          // onPressed: _showOptionsDialog,
                        ),
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

                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 4),
                    child: Row(
                      children: [
                        Chip(
                          backgroundColor: onboardingColor,
                          label: Text(
                            "Filters (1)",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        SizedBox(width: 6),

                        FilterChip(
                          onSelected: (bool selected) {
                            if (selected) {
                              setState(() {
                                _selectedChip = SearchOption.title;
                                _selectedSearchOption = SearchOption.title;
                                _formKey.currentState?.reset();
                              });
                            }
                          },
                          selected: _selectedChip == SearchOption.title,
                          selectedColor: onboardingColor,
                          backgroundColor: Colors.grey[300],
                          label: Text(
                            "Title",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        SizedBox(width: 8),

                        FilterChip(
                          onSelected: (bool selected) {
                            if (selected) {
                              setState(() {
                                _selectedChip = SearchOption.category;
                                _selectedSearchOption = SearchOption.category;
                                _formKey.currentState?.reset();
                              });
                            }
                          },
                          selected: _selectedChip == SearchOption.category,
                          selectedColor: onboardingColor,
                          backgroundColor: Colors.grey[300],
                          label: Text(
                            "Category",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Search Results',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),

                        Text(
                          'Results (${_searchResults.length})',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: onboardingTextColor,
                            height: 1.40,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _searchResults.isEmpty
                      ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Center(child: Text("No results")),
                      )
                      : Container(),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: GridView.builder(
                      shrinkWrap: true,
                      // Important to make GridView work inside SingleChildScrollView
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Number of columns
                        crossAxisSpacing: 10.0, // Horizontal space between cards
                        mainAxisSpacing: 14.0, // Vertical space between cards
                        childAspectRatio: 0.78, // Adjust to fit content (width / height)
                      ),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final postData = _searchResults[index].data() as Map<String, dynamic>;
                        final postId = _searchResults[index].id;

                        // return ProductCard(postData: popularPostsData[index]);
                        return ProductCard(
                          postData: postData,
                          postId: postId,
                          firebaseService: firebaseService,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 42),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final Map<String, dynamic> postData;
  final String postId;

  final FirebaseService firebaseService;

  const ProductCard({super.key, required this.postData, required this.postId, required this.firebaseService});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    final location = widget.postData['location'] as Map<String, dynamic>? ?? {};
    final city = location['city'] as String? ?? 'N/A';
    final price = widget.postData['price']?.toString() ?? '0';
    final likes = widget.postData['likes']?.toString() ?? '0';
    final views = widget.postData['views']?.toString() ?? '0';

    final currentUserId = widget.firebaseService.currentUser?.uid;
    final List<dynamic> likedBy = widget.postData['likedBy'] ?? [];
    final bool isLiked = currentUserId != null && likedBy.contains(currentUserId);

    final createdAtTimestamp = widget.postData['createdAt'] as Timestamp?;
    final postedAgoText = createdAtTimestamp != null ? formatTimeAgo(createdAtTimestamp) : 'Just now';

    return GestureDetector(
      onTap: () {
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsScreen(postId: widget.postId, didComeFromManagedPosts: false),
            ),
          ).then((_) {
            if (mounted) {
              setState(() {});
            }
          });
        }
      },
      child: Container(
        // width: 170,
        // height: 200,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(color: Color(0x3F8A8A8A), spreadRadius: 0, blurRadius: 9, offset: Offset(0, 1)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12.0),
                      topRight: Radius.circular(12.0),
                      bottomLeft: Radius.circular(12.0),
                      bottomRight: Radius.circular(12.0),
                    ),
                    child: Image.asset(
                      "images/backgrounds/cow_2.png",
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.white70, shape: BoxShape.circle),

                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border_outlined,
                        color: isLiked ? Colors.red : Colors.grey,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Divider(color: dividerColor)),

            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$$price',
                    style: GoogleFonts.poppins(
                      color: onboardingColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: popularPostsLocationTextColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          // widget.postData['location'],
                          city,
                          style: GoogleFonts.poppins(
                            color: popularPostsLocationTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // const Spacer(), // Pushes likes to the right if location text is short
                      Icon(Icons.favorite, size: 16, color: Colors.redAccent),
                      const SizedBox(width: 4),
                      Text(
                        // widget.postData['likes'].toString(),
                        likes,
                        style: GoogleFonts.poppins(
                          color: popularPostsLocationTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time_outlined, size: 16, color: popularPostsLocationTextColor),
                      const SizedBox(width: 4),
                      Text(
                        // widget.postData['createdAt'].toString(),
                        postedAgoText,
                        style: GoogleFonts.poppins(
                          color: popularPostsLocationTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(), // Pushes views to the right
                      const Icon(Icons.visibility_outlined, size: 16, color: onboardingColor),
                      const SizedBox(width: 4),
                      Text(
                        // widget.postData['views'].toString(),
                        views,
                        style: GoogleFonts.poppins(
                          color: popularPostsLocationTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
