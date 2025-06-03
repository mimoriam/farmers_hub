import 'package:flutter/material.dart';

import 'package:farmers_hub/utils/constants.dart';

import 'package:google_fonts/google_fonts.dart';
class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: homebackgroundColor,
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        backgroundColor: onboardingColor,
        automaticallyImplyLeading: true,
        title: Text(
          "Details",
          // style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      
      body: SafeArea(child: SingleChildScrollView(

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleAndActions(),
                  const SizedBox(height: 8),

                  _buildEngagementStats(),
                  const SizedBox(height: 16),

                  _buildSellerInfo(),
                  const SizedBox(height: 24),

                  _buildActionButtons(context),
                  const SizedBox(height: 24),

                  _buildVerifiedSellerBadge(),
                  const SizedBox(height: 16),

                  _buildDetailsSection(),
                ],
              ),
            ),
          ],
        ),
      ),),
    );
  }
}

Widget _buildImageSection() {
  return Stack(
    children: [
      // Placeholder for the image. Replace with Image.network or Image.asset
      Container(
        height: 250,
        child: Image.asset(
          "images/backgrounds/cow_2.png",
          width: double.infinity,
          fit: BoxFit.cover,
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
          child: const Text(
            '1/4',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    ],
  );
}

Widget _buildTitleAndActions() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Healthy female cow along with her calf, available for sale.',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rs. 330,000',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: onboardingColor),
              ),
              const SizedBox(height: 4),
              Text(
                'Mirpur Mathelo, PK',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
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
              IconButton(
                icon: const Icon(Icons.favorite_border_outlined),
                // icon: Icon(Icons.favorite, color: Colors.red), // For liked state
                onPressed: () {
                  // Handle favorite action
                },
                color: Colors.grey[700],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

Widget _buildEngagementStats() {
  return Row(
    children: [
      Icon(Icons.favorite, color: Colors.red[400], size: 16),
      const SizedBox(width: 4),
      const Text('Likes 4', style: TextStyle(fontSize: 12, color: Colors.grey)),
      const SizedBox(width: 16),
      Icon(Icons.visibility_outlined, color: Colors.grey[600], size: 16),
      const SizedBox(width: 4),
      const Text('Views: 275', style: TextStyle(fontSize: 12, color: Colors.grey)),
      const Spacer(),
      Text(
        '2 months ago',
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
    ],
  );
}

Widget _buildSellerInfo() {
  return Row(
    children: [
      const CircleAvatar(
        radius: 24,
        backgroundColor: Colors.purple, // Color from the 'M'
        child: Text(
          'M',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
      const SizedBox(width: 12),
      const Text(
        'Loreum ipsum', // Placeholder name
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ],
  );
}

Widget _buildActionButtons(BuildContext context) {
  return Row(
    children: [
      Expanded(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
          label: const Text('Chat', style: TextStyle(color: Colors.white)),
          onPressed: () {
            // Handle Chat action
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: onboardingColor,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      // const SizedBox(width: 10),
    ],
  );
}

Widget _buildVerifiedSellerBadge() {
  return Align(
    alignment: Alignment.centerLeft,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.yellow[700],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Verified Seller',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    ),
  );
}

Widget _buildDetailsSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildDetailRow('Category:', 'Cow'),
      _buildDetailRow('Gender:', 'Female'),
      _buildDetailRow('Average Weight (in kg):', '300.00'),
      _buildDetailRow('Age (in years):', '62.0'), // Note: unusual age
      _buildDetailRow('Phone Number:', '+92 123456789'),
      const SizedBox(height: 8),
      const Text(
        'Additional Information',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      // Add Text widget here if there is additional info text
      // Text('Some additional details about the cow and calf...'),
    ],
  );
}

Widget _buildDetailRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    ),
  );
}
