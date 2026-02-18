import 'package:flutter/material.dart';

class BinInfoScreen extends StatelessWidget {
  final String title;
  final Color color;
  final List<Map<String, dynamic>> items;
  final String message;
  final String imagePath;

  const BinInfoScreen({
    super.key,
    required this.title,
    required this.color,
    required this.items,
    required this.message,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f5d9),
      appBar: AppBar(title: Text(title), backgroundColor: color),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Bin Image
            Image.asset(imagePath, height: 120),

            const SizedBox(height: 12),

            /// Title
            Text(
              "What goes here?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),

            const SizedBox(height: 6),

            /// Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 18),

            Column(
              children: items.map((section) {
                final String category = section["category"];
                final List sectionItems = section["items"];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🏷 CATEGORY TITLE
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),

                    /// GRID FOR THAT CATEGORY
                    GridView.builder(
                      itemCount: sectionItems.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.0,
                          ),
                      itemBuilder: (_, i) {
                        final item = sectionItems[i];

                        return BlobItemCard(
                          image: item["image"],
                          label: item["label"],
                          color: color,
                        );
                      },
                    ),
                  ],
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            /// Encouragement text for kids
            const Text(
              "Great job sorting your trash! 🌍♻️",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BlobItemCard extends StatelessWidget {
  final String image;
  final String label;
  final Color color;

  const BlobItemCard({
    super.key,
    required this.image,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 42),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
