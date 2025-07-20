import 'package:carousel_slider/carousel_slider.dart';
import 'package:farmers_hub/utils/constants.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class DetailsImages extends StatefulWidget {
  final List<String> items;
  const DetailsImages({super.key, required this.items});

  @override
  State<DetailsImages> createState() => _DetailsImagesState();
}

class _DetailsImagesState extends State<DetailsImages> {
  // 1. CONTROLLERS & STATE
  // Controller to manage carousel actions
  final CarouselController _carouselController = CarouselController();
  // A controller for each image to track its transformation (zoom/pan)
  late List<TransformationController> _transformationControllers;
  // State to track which page is currently viewed and which is zoomed
  int _currentPage = 0;
  late List<bool> _isZoomed;

  @override
  void initState() {
    super.initState();

    // 2. INITIALIZATION
    // Initialize a controller and a zoom state for each image
    _transformationControllers = List.generate(
      widget.items.length,
      (_) => TransformationController(),
    );
    _isZoomed = List.generate(widget.items.length, (_) => false);

    // Add listeners to each controller to update the zoom state
    for (int i = 0; i < widget.items.length; i++) {
      _transformationControllers[i].addListener(() {
        // Check if the image is zoomed in (scale > 1.0)
        final bool isZoomedNow = _transformationControllers[i].value.getMaxScaleOnAxis() > 1.0;
        // If the zoom state has changed, update the UI
        if (isZoomedNow != _isZoomed[i]) {
          setState(() {
            _isZoomed[i] = isZoomedNow;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    // 3. DISPOSE CONTROLLERS
    // Clean up the controllers to prevent memory leaks
    for (final controller in _transformationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CarouselSlider(
        items: widget.items.mapIndexed((index, element) {
          final imageUrl = widget.items[index];
          return Builder(
            builder: (BuildContext context) {
              // The container now fills the screen
              return Container(
                margin: EdgeInsets.all(5),
                width: width,
                height: height,
                child: InteractiveViewer(
                  // 4. ASSIGN CONTROLLER
                  // Assign the specific controller for this image
                  transformationController: _transformationControllers[index],
                  panEnabled: true,
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.fitWidth, // Ensures the image covers the screen
                    height: height,
                    width: width,
                  ),
                ),
              );
            },
          );
        }).toList(),
        options: CarouselOptions(
          height: height,
          viewportFraction: 1.0,
          scrollDirection: Axis.vertical,
          initialPage: 0,
          enlargeCenterPage: false,
          // 5. CONDITIONAL LOGIC
          // Disable carousel scrolling if the CURRENT image is zoomed
          scrollPhysics: _isZoomed[_currentPage]
              ? const NeverScrollableScrollPhysics()
              : const PageScrollPhysics(),
          // Stop autoplay if the CURRENT image is zoomed
          autoPlay: !_isZoomed[_currentPage],
          // Update the current page index when the slide changes
          onPageChanged: (index, reason) {
            setState(() {
              _currentPage = index;
            });
          },
        ),
      ),
    );
  }
}
