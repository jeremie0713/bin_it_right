import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'scan_screen.dart';
import 'games_menu_screen.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'bin_info_screen.dart';

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

  final List<Map<String, dynamic>> binData = [
    {
      "title": "Non-Recyclable",
      "color": const Color(0xFFff4f63),
      "image": "assets/images/non_recyclable.png",
      "items": [
        {
          "category": "Contaminated Hygiene Waste",
          "items": [
            {"image": "assets/game/diaper_1.png", "label": "Diaper"},
            {"image": "assets/game/diaper_2.png", "label": "Diaper"},
            {"image": "assets/game/mask.png", "label": "Mask"},
            {"image": "assets/game/dirty_gloves.png", "label": "Dirty gloves"},
            {
              "image": "assets/game/toothbrush_trash.png",
              "label": "Toothbrush",
            },
          ],
        },
        {
          "category": "Wrappers and Mixed / Hard Plastics",
          "items": [
            {
              "image": "assets/game/candy_wrapper.png",
              "label": "Candy wrapper",
            },
            {"image": "assets/game/chip_bag.png", "label": "Chip bag"},
            {"image": "assets/game/straw_1.png", "label": "Straw"},
          ],
        },
        {
          "category": "Broken / Damaged / Hazardous",
          "items": [
            {"image": "assets/game/broken_bulb.png", "label": "Broken bulb"},
            {
              "image": "assets/game/broken_ceramics.png",
              "label": "Broken ceramics",
            },
            {
              "image": "assets/game/broken_gadget.png",
              "label": "Broken gadget",
            },
            {"image": "assets/game/broken_phone.png", "label": "Broken phone"},
            {
              "image": "assets/game/shattered_glass.png",
              "label": "Shattered glass",
            },
          ],
        },
      ],
      "message":
          "These cannot be recycled. Put them in the right bin to keep our world clean!",
    },
    
    {
      "title": "Biodegradable",
      "color": Colors.green,
      "image": "assets/images/biodegradable.png",
      "items": [
        {
          "category": "Food and Natural Waste",
          "items": [
            {"image": "assets/game/apple_core.png", "label": "Apple core"},
            {"image": "assets/game/banana_peel.png", "label": "Banana peel"},
            {
              "image": "assets/game/chicken_leftover.png",
              "label": "Chicken bone",
            },
            {"image": "assets/game/moldy_bread.png", "label": "Moldy bread"},
            {"image": "assets/game/egg_shell_1.png", "label": "Egg shell"},
            {"image": "assets/game/fish_bone.png", "label": "Fish bone"},
            {
              "image": "assets/game/pizza_leftover.png",
              "label": "Pizza leftover",
            },
            {"image": "assets/game/tea_bag.png", "label": "Tea bag"},
            {
              "image": "assets/game/watermelon_peel.png",
              "label": "Watermelon peel",
            },
          ],
        },
      ],
      "message": "These turn into soil and help plants grow! 🌱",
    },

    {
      "title": "Reusable",
      "color": Colors.orange,
      "image": "assets/images/reusable.png",
      "items": [
        {
          "category": "Clothing & Fabric",
          "items": [
            {"image": "assets/game/pants.png", "label": "Pants"},
            {"image": "assets/game/backpack.png", "label": "Backpack"},
            {"image": "assets/game/shirt.png", "label": "Shirt"},
            {"image": "assets/game/shoes.png", "label": "Shoes"},
            {"image": "assets/game/socks.png", "label": "Socks"},
            {"image": "assets/game/old_towel.png", "label": "Old towel"},
          ],
        },
        {
          "category": "Containers & Household Items (Clean)",
          "items": [
            {"image": "assets/game/tumbler_bottle.png", "label": "Tumbler"},
            {
              "image": "assets/game/food_container.png",
              "label": "Food container",
            },
          ],
        },
        {
          "category": "Others",
          "items": [
            {"image": "assets/game/old_books.png", "label": "Old books"},
            {"image": "assets/game/old_toy_car.png", "label": "Toy car"},
          ],
        },
      ],
      "message": "Use them again instead of throwing them away!",
    },

    {
      "title": "Recyclable",
      "color": Colors.blue,
      "image": "assets/images/recyclable.png",
      "items": [
        {
          "category": "Paper and Cardboard",
          "items": [
            {"image": "assets/game/cardboard_2.png", "label": "Cardboard"},
            {"image": "assets/game/paper_1.png", "label": "Paper"},
            {"image": "assets/game/milk_carton.png", "label": "Milk carton"},
            {
              "image": "assets/game/toilet_paper_core.png",
              "label": "Toilet paper core",
            },
          ],
        },
        {
          "category": "Plastic (Clean)",
          "items": [
            {
              "image": "assets/game/plastic_bottle_2.png",
              "label": "Plastic bottle",
            },
            {"image": "assets/game/plastic_bag_1.png", "label": "Plastic"},
            {"image": "assets/game/plastic_cup_1.png", "label": "Plastic cup"},
            {
              "image": "assets/game/shampoo_bottle.png",
              "label": "Shampoo bottle",
            },
            {
              "image": "assets/game/detergent_bottle.png",
              "label": "Detergent bottle",
            },
          ],
        },
        {
          "category": "Metal",
          "items": [
            {"image": "assets/game/can_1.png", "label": "Can"},
            {"image": "assets/game/soda_can_2.png", "label": "Soda can"},
          ],
        },
        {
          "category": "Glass",
          "items": [
            {
              "image": "assets/game/glass_bottle_1.png",
              "label": "Glass Bottle",
            },
            {"image": "assets/game/glass_jar.png", "label": "Glass Jar"},
          ],
        },
      ],
      "message": "These can become new things. Recycle to save energy!",
    },
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

              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Text(
                  'Click and see what\'s in the bin!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.white70,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ),

              // FlutterCarousel Widget
              Positioned(
                bottom: -9,
                left: 0,
                right: 0,
                child: FlutterCarousel(
                  options: FlutterCarouselOptions(
                    height: 240,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayCurve: Curves.easeInOut,
                    enlargeCenterPage: true,
                    enlargeFactor: 0.35,
                    showIndicator: false,
                    enableInfiniteScroll: true,
                    viewportFraction: 0.50, // 👈 shows side bins
                    onPageChanged: (index, reason) {
                      setState(() => _currentPage = index);
                    },
                  ),
                  items: List.generate(carouselImages.length, (index) {
                    final imagePath = carouselImages[index];
                    final data = binData[index];

                    return GestureDetector(
                      onTap: () {
                        if (_currentPage != index) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BinInfoScreen(
                              title: data["title"],
                              color: data["color"],
                              items: List<Map<String, dynamic>>.from(
                                data["items"],
                              ),
                              message: data["message"],
                              imagePath: data["image"],
                            ),
                          ),
                        );
                      },

                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 8,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Stack(
                            children: [
                              Container(
                                color: Colors
                                    .transparent, // removes white background look
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit
                                      .contain, // 👈 keeps full bin visible
                                  width: double.infinity,
                                ),
                              ),
                            ],
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
