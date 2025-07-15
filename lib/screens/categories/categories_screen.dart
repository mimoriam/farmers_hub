import 'package:farmers_hub/generated/i18n/app_localizations.dart';
import 'package:farmers_hub/screens/filtered_results/filtered_results_screen.dart';
import 'package:farmers_hub/screens/land/land_screen.dart';
import 'package:flutter/material.dart';

import 'package:farmers_hub/utils/constants.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final validateMode = AutovalidateMode.onUserInteraction;

  String _searchQuery = "";

  List<Map<String, String>> _filteredCategories = [];

  final List<Map<String, String>> categories = [
    {'name': 'Fruits', 'image': 'images/categories/fruits.png', "t": "فواكه"},
    {'name': 'Vegetables', 'image': 'images/categories/vegetables.png', "t": "خضروات"},
    {'name': 'Olive Oil', 'image': 'images/categories/olive_oil.png', "t": "زيت الزيتون"},
    {'name': 'Live Stock', 'image': 'images/categories/live_stock.png', "t": "المواشي"},
    {'name': 'Grain & Seeds', 'image': 'images/categories/grains_and_seeds.jpg', "t": "حبوب وبذور"},
    {'name': 'Fertilizers', 'image': 'images/categories/fertilizers.jpg', "t": "أسمدة"},
    {'name': 'Tools', 'image': 'images/categories/tools_and_equipments.jpg', "t": "أدوات"},
    {'name': 'Land Services', 'image': 'images/categories/land_services.jpg', "t": "خدمات الأراضي"},
    {'name': 'Equipments', 'image': 'images/categories/equipments.jpg', "t": "معدات"},
    {'name': 'Delivery', 'image': 'images/categories/delivery.jpg', "t": "توصيل"},
    {
      'name': 'Worker Services',
      'image': 'images/categories/worker_services.jpg',
      "t": "خدمات العمال",
    },
    {'name': 'Pesticides', 'image': 'images/categories/pesticides.jpg', "t": "مبيدات حشرية"},
    {'name': 'Animal Feed', 'image': 'images/categories/animal_feed.jpg', "t": "علف الحيوانات"},
    {'name': 'Jams & Molasses', 'image': 'images/categories/jam.png', "t": "المربى والدبس"},
    {'name': 'Irrigation System', 'image': 'images/categories/irrigation.png', "t": "نظام الري"},
    {'name': 'Others', 'image': 'images/categories/others.png', "t": "أخرى"},
  ];

  final List<Map<String, String>> popularCategories = [
    {'name': 'Pomegranate', 'image': 'images/categories/iv_pomegranate.png', "t": "رمان"},
    {'name': 'Apples', 'image': 'images/categories/apples.png', "t": "التفاح"},
    {'name': 'Honey', 'image': 'images/categories/honey.png', "t": "عسل"},
    {'name': 'Cheese', 'image': 'images/categories/iv_cheese.png', "t": "جبن"},
    {'name': 'Leafy Green', 'image': 'images/categories/leafy_green.png', "t": "الورقية الخضراء"},
    // {'name': 'Tomatoes', 'image': 'images/categories/tomatoes.jpg'},
    // {'name': 'Rice', 'image': 'images/categories/rice.jpg'},
  ];

  // Method to filter categories based on the search query
  void _filterCategories(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredCategories = List.from(categories);
      } else {
        _filteredCategories = categories
            .where((category) => category['name']!.toLowerCase().contains(_searchQuery))
            .toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Initially, show all categories
    _filteredCategories = List.from(categories);
  }

  Widget _buildCategoryItem(BuildContext context, String name, String imageUrl, String t) {
    final locale = Localizations.localeOf(context);

    return GestureDetector(
      onTap: () {
        if (name == "Land Services") {
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    // TODO: Add Searching for Land stuff
                    (context) => LandScreen(categoryOption: "Land"),
              ),
            );
          }
        } else if (name == "Equipments") {
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    // TODO: Add Searching for Land stuff
                    (context) => LandScreen(categoryOption: "Equipments"),
              ),
            );
          }
        } else if (name == "Delivery") {
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    // TODO: Add Searching for Land stuff
                    (context) => LandScreen(categoryOption: "Delivery"),
              ),
            );
          }
        } else {
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FilteredResultsScreen(
                  searchQuery: name.split(' ')[0].toLowerCase(),
                  selectedSearchOption: SearchOption.category,
                ),
              ),
            );
          }
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
            padding: const EdgeInsets.all(12.0),
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
                  // name,
                  locale.languageCode == "ar" ? t : name,
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
    final locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: homebackgroundColor,
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        backgroundColor: onboardingColor,
        automaticallyImplyLeading: true,
        title: Text(
          // "Search Categories",
          AppLocalizations.of(context)!.searchCategories,
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
                  // SvgPicture.asset(
                  //   "images/icons/apple.svg",
                  //   colorFilter: ColorFilter.mode(onboardingColor, BlendMode.srcIn),
                  //   width: 100,
                  //   height: 100,
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20, top: 20),
                    child: FormBuilderTextField(
                      name: "search",
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: 13.69,
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                        ),
                      ),
                      onChanged: (String? query) {
                        _filterCategories(query ?? '');
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

                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            AppLocalizations.of(context)!.categories,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              height: 1.71,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        _filteredCategories.isEmpty && _searchQuery.isNotEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                                  child: Text(
                                    'No categories found for "$_searchQuery"',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                // Important to make GridView work inside SingleChildScrollView
                                physics: const NeverScrollableScrollPhysics(),
                                // Disable GridView's own scrolling
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // Number of columns
                                  crossAxisSpacing: 16.0, // Horizontal spacing between items
                                  mainAxisSpacing: 10.0, // Vertical spacing between items
                                  childAspectRatio: 1.2,
                                ),
                                // itemCount: categories.length,
                                itemCount: _filteredCategories.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final category = _filteredCategories[index];
                                  return _buildCategoryItem(
                                    context,
                                    category["name"]!,
                                    category["image"]!,
                                    category["t"]!,
                                  );
                                },
                              ),

                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 20),
                          child: Text(
                            // 'Popular Categories',
                            AppLocalizations.of(context)!.popularCategories,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              height: 1.71,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        // SvgPicture.asset(
                        //   "images/icons/apple.svg",
                        //   width: 200,
                        //   height: 200,
                        // ),
                        SizedBox(
                          height: 130.0,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: popularCategories.length,
                            itemBuilder: (BuildContext context, int index) {
                              final category = popularCategories[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: index == popularCategories.length - 1 ? 0 : 12.0,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (context.mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => FilteredResultsScreen(
                                              // TODO: Handle when Category has spaces in them
                                              searchQuery: category["name"]!.toLowerCase(),
                                              selectedSearchOption: SearchOption.category,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      width: 128,
                                      height: 102,
                                      padding: const EdgeInsets.all(12),
                                      decoration: ShapeDecoration(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            width: 0.2,
                                            color: const Color(0xFFFF9800),
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        shadows: [
                                          BoxShadow(
                                            color: Color(0x0C000000),
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 9),
                                            child: SizedBox(
                                              width: 48,
                                              height: 46,

                                              child: Image.asset(
                                                category['image']!,
                                                fit: BoxFit.contain,
                                              ),
                                              // child: SvgPicture.asset(
                                              //   category['image']!,
                                              //   semanticsLabel: category["semanticsLabel"],
                                              //   width: 20,
                                              //   height: 20,
                                              //   placeholderBuilder: (BuildContext context) => const CircularProgressIndicator(),
                                              // ),
                                            ),
                                          ),
                                          Text(
                                            // category["name"]!,
                                            locale.languageCode == "ar"
                                                ? category["t"]!
                                                : category["name"]!,
                                            style: TextStyle(
                                              color: const Color(0xFF505050),
                                              fontSize: 13.69,
                                              fontWeight: FontWeight.w400,
                                              height: 1.43,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
