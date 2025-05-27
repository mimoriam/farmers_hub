import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import 'package:farmers_hub/utils/constants.dart';

import 'package:farmers_hub/services/firebase_service.dart';
import 'package:farmers_hub/screens/login/login_screen.dart';
import 'package:farmers_hub/screens/categories/categories_screen.dart';
import 'package:farmers_hub/screens/filtered_results/filtered_results_screen.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';

class UpwardNotchedAndRoundedRectangle extends NotchedShape {
  final double topCornerRadius;
  final double bottomCornerRadius;

  const UpwardNotchedAndRoundedRectangle({this.topCornerRadius = 0.0, this.bottomCornerRadius = 0.0});

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    final Path path = Path();

    if (guest == null || !host.overlaps(guest)) {
      // If no guest or no overlap, draw a simple rounded rectangle for the host.
      path.addRRect(
        RRect.fromRectAndCorners(
          host,
          topLeft: Radius.circular(topCornerRadius),
          topRight: Radius.circular(topCornerRadius),
          bottomLeft: Radius.circular(bottomCornerRadius),
          bottomRight: Radius.circular(bottomCornerRadius),
        ),
      );
      return path;
    }

    // Guest (FAB) properties
    final double fabRadius = guest.width / 2.0;
    final double fabDiameter = guest.width;
    final Offset fabCenter = guest.center; // Horizontal center of FAB relative to host

    // Points where the upward bump meets the straight top edge of the host
    final double leftBumpEdgeX = fabCenter.dx - fabRadius;
    final double rightBumpEdgeX = fabCenter.dx + fabRadius;

    // Start path from bottom-left, going clockwise.
    if (bottomCornerRadius > 0) {
      path.moveTo(host.left + bottomCornerRadius, host.bottom);
      path.arcTo(
        Rect.fromLTWH(
          host.left,
          host.bottom - bottomCornerRadius * 2,
          bottomCornerRadius * 2,
          bottomCornerRadius * 2,
        ),
        math.pi / 2, // Start angle (90 deg) for bottom-left
        math.pi / 2, // Sweep angle (90 deg)
        false,
      );
    } else {
      path.moveTo(host.left, host.bottom);
    }

    // Left edge up to the start of the top-left corner
    path.lineTo(host.left, host.top + topCornerRadius);

    // Top-left rounded corner
    if (topCornerRadius > 0) {
      path.arcTo(
        Rect.fromLTWH(host.left, host.top, topCornerRadius * 2, topCornerRadius * 2),
        math.pi, // Start angle (180 deg) for top-left
        math.pi / 2, // Sweep angle (90 deg)
        false,
      );
    } else {
      // If no radius, just a straight line to the corner
      path.lineTo(host.left, host.top);
    }

    // Line from top-left corner to start of upward bump
    path.lineTo(leftBumpEdgeX, host.top);

    // Upward semicircular arc for the notch/bump
    // The circle containing the arc is centered at (fabCenter.dx, host.top)
    // with radius fabRadius.
    Rect arcRect = Rect.fromCircle(center: Offset(fabCenter.dx, host.top), radius: fabRadius);
    // Start angle 'math.pi' (9 o'clock on the circle) corresponds to (leftBumpEdgeX, host.top).
    // Sweep angle 'math.pi' (180 degrees counter-clockwise) traces the upper semicircle.
    path.arcTo(arcRect, math.pi, math.pi, false);

    // Line from end of upward bump to start of top-right corner
    path.lineTo(host.right - topCornerRadius, host.top);

    // Top-right rounded corner
    if (topCornerRadius > 0) {
      path.arcTo(
        Rect.fromLTWH(host.right - topCornerRadius * 2, host.top, topCornerRadius * 2, topCornerRadius * 2),
        math.pi * 3 / 2, // Start angle (270 deg) for top-right
        math.pi / 2, // Sweep angle (90 deg)
        false,
      );
    } else {
      // If no radius, just a straight line to the corner
      path.lineTo(host.right, host.top);
    }

    // Right edge down to the start of the bottom-right corner
    path.lineTo(host.right, host.bottom - bottomCornerRadius);

    // Bottom-right rounded corner
    if (bottomCornerRadius > 0) {
      path.arcTo(
        Rect.fromLTWH(
          host.right - bottomCornerRadius * 2,
          host.bottom - bottomCornerRadius * 2,
          bottomCornerRadius * 2,
          bottomCornerRadius * 2,
        ),
        0, // Start angle (0 deg) for bottom-right
        math.pi / 2, // Sweep angle (90 deg)
        false,
      );
    }

    path.close(); // Connects to the starting point (around bottom-left corner)

    return path;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final firebaseService = FirebaseService();

  int _currentCarouselPage = 0; // To keep track of the current carousel page

  // Placeholder image URLs for the carousel
  final List<String> imgList = [
    'images/backgrounds/tractor_ad.jpg',
    'images/backgrounds/olive_oil_bottle.jpg',
    'images/backgrounds/dry_fruits.jpg',
    'images/backgrounds/food_marketplace.jpg',
    'images/backgrounds/pomegranates.jpg',
  ];

  Widget _buildCategoryItem(String name, String imageUrl) {
    return GestureDetector(
      onTap: () {
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CategoriesScreen()),
          );
        }
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: BorderSide(color: categoriesBorderColor, width: 1),
        ),
        color: Colors.white,
        child: InkWell(
          // onTap: () {
          //   // TODO: Implement navigation or action for category item
          // },
          borderRadius: BorderRadius.circular(10.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0), // Space between image and text
                    // Use Image.network here to dynamically load from DB
                    child: Image.asset(
                      imageUrl,
                      fit: BoxFit.contain, // Use contain to see the whole placeholder image
                      // Error handling for image loading
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image, size: 40, color: Colors.grey);
                      },
                    ),
                  ),
                ),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: categoriesTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.54,
                  ),
                  overflow: TextOverflow.ellipsis, // Handle long text
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: scaffoldBackgroundColor);

    final List<Map<String, String>> categories = [
      {'name': 'Fruits', 'image': 'images/categories/fruits.png'},
      {'name': 'Vegetables', 'image': 'images/categories/vegetables.png'},
      {'name': 'Olive Oil', 'image': 'images/categories/olive_oil.png'},
      {'name': 'Grain & Seeds', 'image': 'images/categories/grains_and_seeds.jpg'},
      {'name': 'Equipments', 'image': 'images/categories/equipments.jpg'},
      {'name': 'Live Stock', 'image': 'images/categories/live_stock.png'},
    ];

    final List<Map<String, dynamic>> popularPostsData = const [
      {
        "image_url": "images/backgrounds/fertilizers_spray.jpg",
        "price": "330,000",
        "location": "Mirpur Mathelo",
        "likes": 4,
        "posted_ago": "02 Months Ago",
        "views": 274,
      },

      {
        "image_url": "images/backgrounds/cow.png",
        "price": "330,000",
        "location": "Mirpur Mathelo",
        "likes": 12,
        "posted_ago": "02 Months Ago",
        "views": 301,
      },

      {
        "image_url": "images/backgrounds/cow.png",
        "price": "430,000",
        "location": "Mirpur Mathelo",
        "likes": 12,
        "posted_ago": "02 Months Ago",
        "views": 301,
      },
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (didPop) {
            // If the route is popped, exit the app
          } else {
            // Show a confirmation dialog before allowing the pop
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: scaffoldBackgroundColor,
                  title: Text("Confirm Exit"),
                  content: Text("Are you sure you want to exit the app?"),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Don't exit
                      },
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        SystemNavigator.pop();
                      },
                      child: Text("Exit"),
                    ),
                  ],
                );
              },
            );
          }
        },
        child: Scaffold(
          backgroundColor: homebackgroundColor,
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            backgroundColor: onboardingColor,
            elevation: 4,
            shape: CircleBorder(),
            child: Icon(Icons.camera_alt_outlined, color: Colors.white, size: 24),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            height: 70,
            shape: const UpwardNotchedAndRoundedRectangle(topCornerRadius: 12),
            notchMargin: 10,
            color: Colors.white,
            elevation: 0,
            // Shadow for the BottomAppBar
            clipBehavior: Clip.antiAlias,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              // Children are the navigation items
              children: <Widget>[
                Column(
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
                Column(
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
                const SizedBox(width: 6),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(semanticsLabel: 'Favorites Icon', "images/icons/favorites.svg"),
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
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(semanticsLabel: 'Profile Icon', "images/icons/user.svg"),
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
              ],
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Picker
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 20),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Location: ',
                            style: GoogleFonts.poppins(
                              color: locationTextColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              height: 1.22,
                            ),
                          ),

                          TextSpan(
                            text: 'City, Country',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.96,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.location_on_outlined, size: 20, color: onboardingColor),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(width: 1, color: textFieldBorderSideColor),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            backgroundColor: homebackgroundColor,
                            elevation: 0,
                          ),
                          label: Text(
                            'Select Location',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              color: onboardingColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 10, left: 20),
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                              backgroundColor: onboardingColor,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              "Go",
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.notifications_none_outlined),
                          style: IconButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                            backgroundColor: onboardingColor,
                            foregroundColor: Colors.white,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10),

                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          // MaterialPageRoute(builder: (context) => const CategoriesScreen()),
                          MaterialPageRoute(builder: (context) => const FilteredResultsScreen()),
                        );
                      }
                    },
                    child: IgnorePointer(
                      ignoring: true,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                        child: FormBuilderTextField(
                          name: "search",
                          readOnly: true,
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(fontSize: 13.69, fontWeight: FontWeight.w400, height: 1.43),
                            color: Colors.grey,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search',
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
                    ),
                  ),

                  Column(
                    children: [
                      CarouselSlider.builder(
                        itemCount: imgList.length,
                        itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              // color: Colors.grey[300], // Placeholder background if image fails
                              color: Colors.green,
                              // borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ClipRRect(
                              // borderRadius: BorderRadius.circular(12.0),
                              child: Image.asset(imgList[itemIndex], fit: BoxFit.fill),
                            ),
                          );
                        },
                        options: CarouselOptions(
                          height: 200.0,
                          viewportFraction: 1,
                          enableInfiniteScroll: true,
                          autoPlay: true,
                          // enlargeCenterPage: true,
                          // enlargeFactor: 1,
                          autoPlayInterval: Duration(seconds: 3),
                          autoPlayAnimationDuration: Duration(milliseconds: 1000),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          scrollDirection: Axis.horizontal,
                          onPageChanged: (index, reason) {
                            // Added for fixing the freeze bug on animation:
                            Future.delayed(const Duration(milliseconds: 650), () {
                              setState(() {
                                _currentCarouselPage = index; // Update the current page index
                              });
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 4),

                      StatefulBuilder(
                        builder: (BuildContext context, StateSetter setStateDots) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:
                                imgList.asMap().entries.map((entry) {
                                  return GestureDetector(
                                    onTap: () {
                                      // Optional: Allow tapping dots to change carousel page
                                      // _carouselController.animateToPage(entry.key);
                                    },
                                    child: Container(
                                      width: _currentCarouselPage == entry.key ? 26 : 14,
                                      height: 6.0,
                                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                      decoration: ShapeDecoration(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        color:
                                            _currentCarouselPage == entry.key
                                                ? onboardingColor
                                                : carouselGrey,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          );
                        },
                      ),
                    ],
                  ),

                  // Weather card:
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Container(
                      width: 400,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

                        gradient: LinearGradient(
                          begin: Alignment(0.00, 0.50),
                          end: Alignment(1.00, 0.50),
                          colors: [const Color(0x194CAF50), const Color(0x19FF9800)],
                        ),
                      ),

                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 11,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.wb_sunny_outlined, size: 36.0, color: onboardingColor),
                                    const SizedBox(width: 12.0),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '32°C',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 17.6,
                                            fontWeight: FontWeight.w600,
                                            height: 1.56,
                                          ),
                                        ),
                                        Text(
                                          'Clear Sky',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13.6,
                                            fontWeight: FontWeight.w400,
                                            height: 1.43,
                                            color: clearSkyText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                // Right side: Date and day
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'April 22, 2025',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13.6,
                                          fontWeight: FontWeight.w500,
                                          height: 1.43,
                                        ),
                                      ),
                                      Text(
                                        'Tuesday',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: clearSkyText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(top: 12.7),

                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(width: 0.98, color: const Color(0xFFE5E7EB)),
                              ),
                            ),

                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: SvgPicture.asset(
                                    semanticsLabel: 'Plant Icon',
                                    "images/icons/farming_icon.svg",
                                    width: 20,
                                    height: 20,
                                  ),
                                  // child: Icon(
                                  //   Icons.agriculture_outlined,
                                  //   size: 28,
                                  //   color: Colors.orange[600],
                                  // ),
                                ),
                                const SizedBox(width: 8.0),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Farming Tip of the Day',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        'Perfect day for soil preparation and planting seedlings. Moisture levels are optimal.',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w400,
                                          color: clearSkyText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Categories
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Categories',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                height: 1.71,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                if (context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const CategoriesScreen()),
                                  );
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'View all',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: onboardingColor,
                                      height: 1.43,
                                    ),
                                  ),
                                  Icon(Icons.chevron_right, color: onboardingColor, size: 18),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Grid view for categories
                        GridView.count(
                          crossAxisCount: 3,
                          // 3 items per row
                          shrinkWrap: true,
                          // Important to make GridView work inside ListView
                          physics: const NeverScrollableScrollPhysics(),
                          // Disable GridView's own scrolling
                          mainAxisSpacing: 10.0,
                          crossAxisSpacing: 1.0,
                          children:
                              categories.map((category) {
                                return _buildCategoryItem(category["name"]!, category["image"]!);
                              }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text(
                          "Popular Posts",
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(width: 8),

                        SvgPicture.asset(
                          'images/icons/flame_icon.svg',
                          semanticsLabel: "Flame Icon",
                          width: 20,
                          height: 20,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: SizedBox(
                      height: 240,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: popularPostsData.length,
                        itemBuilder: (context, index) {
                          final post = popularPostsData[index];
                          return PostCard(
                            imageUrl: post['image_url']!,
                            price: post['price']!,
                            location: post['location']!,
                            likes: post['likes']!,
                            postedAgo: post['posted_ago']!,
                            views: post['views']!,
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 8),
                    child: Container(
                      width: 360,
                      padding: EdgeInsets.only(left: 16, top: 16, bottom: 16, right: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          // begin: Alignment(0.00, 0.50),
                          // end: Alignment(1.00, 0.50),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [const Color(0x33FF9800), const Color(0x334CAF50)],
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Looking for more as you want!',
                                  style: GoogleFonts.poppins(
                                    color: lookingForMoreText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    height: 1.71,
                                  ),
                                ),
                                Text(
                                  'Explore our Products',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF555F6D),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    height: 1.43,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 16),

                          ElevatedButton(
                            onPressed: () {
                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => FilteredResultsScreen()),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: onboardingColor,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            ),
                            child: Text(
                              'Explore',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                height: 1.50,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        await firebaseService.signOut();
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        }
                      },
                      child: Text("Logout for testing"),
                    ),
                  ),

                  const SizedBox(height: 44),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final String imageUrl;
  final String price;
  final String location;
  final int likes;
  final String postedAgo;
  final int views;

  const PostCard({
    super.key,
    required this.imageUrl,
    required this.price,
    required this.location,
    required this.likes,
    required this.postedAgo,
    required this.views,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 216,
      margin: const EdgeInsets.only(right: 14.0),
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
          // Image with Favorite Icon
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
                  child: Image.asset(imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover),
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
                  'Rs: $price',
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
                        location,
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
                      likes.toString(),
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
                      postedAgo,
                      style: GoogleFonts.poppins(
                        color: popularPostsLocationTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Spacer(), // Pushes views to the right
                    const Icon(Icons.visibility_outlined, size: 16, color: onboardingColor),
                    const SizedBox(width: 4),
                    Text(
                      views.toString(),
                      style: GoogleFonts.poppins(
                        color: popularPostsLocationTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
