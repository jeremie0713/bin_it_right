import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'game_sort_screen.dart';

class GamesMenuScreen extends StatefulWidget {
  const GamesMenuScreen({super.key});

  @override
  State<GamesMenuScreen> createState() => _GamesMenuScreenState();
}

class _GamesMenuScreenState extends State<GamesMenuScreen> {
  int _currentPage = 0;

  final List<String> carouselImages = [
    'assets/images/non_recyclable.png',
    'assets/images/biodegradable.png',
    'assets/images/reusable.png',
    'assets/images/recyclable.png',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/game_menu_bg.gif'),
                fit: BoxFit.fill,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    // FlutterCarousel Widget
                    FlutterCarousel(
                      options: FlutterCarouselOptions(
                        height: 220,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 3),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enlargeCenterPage: true,
                        showIndicator: false,
                        viewportFraction: 0.85,
                        onPageChanged: (index, reason) {
                          setState(() => _currentPage = index);
                        },
                      ),
                      items: carouselImages.map((imagePath) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GameSortScreen(),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.asset(
                                imagePath,
                                fit: BoxFit.fill,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 50,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: ListView(
                        children: [
                          _GameCard(
                            title: "LET'S CLEAN UP",
                            subtitle: "Drag the trash into the correct bin!",
                            imagePath: 'assets/images/clean_up.png',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const GameSortScreen(),
                                ),
                              );
                            },
                          ),
                          _GameCard(
                            title: "CATCH TRASH",
                            subtitle:
                                "Grab the trash and protect rivers and seas!",
                            imagePath: 'assets/images/river_trash.png',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Back button
          Positioned(
            top: 16,
            left: 2,
            child: IconButton(
              icon: const Icon(Icons.arrow_circle_left_rounded, color: Color(0xFFc32b55), size: 35),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imagePath;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color(0xFFdcf5ba),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF7CB342), width: 1),
          ),
          child: Row(
            children: [
              if (imagePath != null)
                Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: Image.asset(
                    imagePath!,
                    width: 140,
                    height: 110,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 140,
                        height: 110,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Song of Valentine Sans',
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF304612),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Winter Draw',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF304612),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
