import 'package:flutter/material.dart';

import 'package:farmers_hub/utils/constants.dart';

import 'package:farmers_hub/screens/details/details_screen.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_fonts/google_fonts.dart';

class FilteredResultsScreen extends StatefulWidget {
  const FilteredResultsScreen({super.key});

  @override
  State<FilteredResultsScreen> createState() => _FilteredResultsScreenState();
}

class _FilteredResultsScreenState extends State<FilteredResultsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final validateMode = AutovalidateMode.onUserInteraction;

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
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.mic_none_outlined, color: onboardingColor),
                          onPressed: null,
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
                          'Results',
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

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Center(child: Text("No results")),
                  ),

                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 10),
                  //   child: GridView.builder(
                  //     shrinkWrap: true,
                  //     // Important to make GridView work inside SingleChildScrollView
                  //     physics: const NeverScrollableScrollPhysics(),
                  //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  //       crossAxisCount: 2, // Number of columns
                  //       crossAxisSpacing: 10.0, // Horizontal space between cards
                  //       mainAxisSpacing: 14.0, // Vertical space between cards
                  //       childAspectRatio: 0.78, // Adjust to fit content (width / height)
                  //     ),
                  //     itemCount: popularPostsData.length,
                  //     itemBuilder: (context, index) {
                  //       return ProductCard(postData: popularPostsData[index]);
                  //     },
                  //   ),
                  // ),
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

  const ProductCard({super.key, required this.postData});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: () {
      //   if (context.mounted) {
      //     Navigator.push(context, MaterialPageRoute(builder: (context) => const DetailsScreen(postId: "1")));
      //   }
      // },
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
                      widget.postData['image_url'],
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
                      child: Icon(Icons.favorite_border_outlined, color: Colors.grey, size: 18),
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
                    'Rs: ${widget.postData['price']}',
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
                          widget.postData['location'],
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
                        widget.postData['likes'].toString(),
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
                        widget.postData['posted_ago'],
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
                        widget.postData['views'].toString(),
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
