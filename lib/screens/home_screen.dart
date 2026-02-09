import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'scan_screen.dart';
import 'games_menu_screen.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _leftCtrl;
  late final AnimationController _rightCtrl;

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

    _leftCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);

    _rightCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _leftCtrl.dispose();
    _rightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/home_bg.gif'),
              fit: BoxFit.fill,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 250,
                right: 150,
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: AnimatedBuilder(
                    animation: _leftCtrl,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _leftCtrl.value * 2 * math.pi,
                        child: Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/sun.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // FlutterCarousel Widget
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: FlutterCarousel(
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
                      onTap: () {},
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
              ),
              // Main content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 120,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 40,
                            top: 10,
                            child: Container(
                              width: 150,
                              height: 100,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/title.png'),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          // GIF positioned at top right
                          Positioned(
                            right: 40,
                            top: 10,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/right.gif'),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _BouncyTile(
                            controller: _leftCtrl,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ScanScreen(),
                                ),
                              );
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    'assets/images/scan_tile.gif',
                                  ), // Your scan tile image
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _BouncyTile(
                            controller: _rightCtrl,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const GamesMenuScreen(),
                                ),
                              );
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    'assets/images/game_tile.gif',
                                  ), // Your games tile image
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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

class _BouncyTile extends StatelessWidget {
  final AnimationController controller;
  final Widget child;
  final VoidCallback onTap;

  const _BouncyTile({
    required this.controller,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        // Smooth bounce using a sine wave
        final t = controller.value;
        final scale = 1.0 + (math.sin(t * math.pi) * 0.035); // bounce amount
        final dy = -math.sin(t * math.pi) * 6.0;

        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.scale(
            scale: scale,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                height: 170,
                decoration: BoxDecoration(
                  color: const Color(0xFFCAE7A2), // light green
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF7CB342), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 14,
                      offset: Offset(0, 8),
                      color: Color(0x22000000),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
