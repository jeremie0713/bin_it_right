import 'package:bin_it_right/screens/catch_trash.dart';
import 'package:flutter/material.dart';
import 'game_sort_screen.dart';
import 'dart:math';

class GamesMenuScreen extends StatefulWidget {
  const GamesMenuScreen({super.key});

  @override
  State<GamesMenuScreen> createState() => _GamesMenuScreenState();
}

class _GamesMenuScreenState extends State<GamesMenuScreen>
    with TickerProviderStateMixin {

  late AnimationController _dancingController;

  @override
  void initState() {
    super.initState();

    _dancingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _dancingController.repeat(reverse: true);
  }

  @override
  void dispose() {

    _dancingController.dispose();

    super.dispose();
  }

  Widget _buildDancingText(String text) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Wrap(
        alignment: WrapAlignment.center,
        children: text.split('').asMap().entries.map((entry) {
          int index = entry.key;
          String letter = entry.value;

          return AnimatedBuilder(
            animation: _dancingController,
            builder: (context, child) {
              double delay = (index * 0.08) % 1.0;
              double animationValue = (_dancingController.value + delay) % 1.0;

              double wave = sin(animationValue * 2 * pi);

              // Bounce effect
              double bounce = wave * 3;

              // Rotation effect
              double rotation = wave * 0.1;

              // 🌿 Color shift
              double colorValue = (wave + 1) / 2;
              // converts -1..1  into 0..1

              Color animatedColor = Color.lerp(
                const Color(0xFF4a7c28),
                const Color(0xFF304612),
                colorValue,
              )!;

              return Transform.translate(
                offset: Offset(0, bounce),
                child: Transform.rotate(
                  angle: rotation,
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontFamily: 'ADELIA',
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: animatedColor,
                      shadows: const [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.black26,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
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
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 250),
                    _buildDancingText(
                      "Have fun while learning how to sort waste correctly!",
                    ),
                    const SizedBox(height: 5),
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
                                  builder: (_) =>  WasteSortingGamePage(),
                                ),
                              );
                            },
                          ),
                          _GameCard(
                            title: "CATCH TRASH",
                            subtitle:
                                "Grab the trash and protect rivers and seas!",
                            imagePath: 'assets/images/river_trash.png',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>  CatchTrash(),
                                ),
                              );
                            },
                          ),
                          _GameCard(
                            title: "WHAT BIN IS IT?",
                            subtitle:
                                "Test your trash sorting skills with this fun quiz game!",
                            imagePath: 'assets/images/what_bin.gif',
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
              icon: const Icon(
                Icons.arrow_circle_left_rounded,
                color: Color(0xFF304612),
                size: 40,
              ),
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

class _GameCard extends StatefulWidget {
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
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard> with SingleTickerProviderStateMixin {
  
  late AnimationController _beatController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _beatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _beatController,
        curve: Curves.easeInOut,
      ),
    );

    _beatController.repeat(reverse: true);
  }

  void dispose() {
    _beatController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color(0xFFdcf5ba),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF7CB342), width: 1),
          ),
          child: Row(
            children: [
              if (widget.imagePath != null)
                Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: child,
                      );
                    },
                    child: Image.asset(
                      widget.imagePath!,
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
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontFamily: 'Song of Valentine Sans',
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF304612),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        fontFamily: 'Simply Olive DEMO',
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
