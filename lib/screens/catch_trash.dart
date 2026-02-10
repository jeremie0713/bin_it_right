import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class CatchTrash extends StatefulWidget {
  const CatchTrash({super.key});

  @override
  _CatchTrashState createState() => _CatchTrashState();
}

class _CatchTrashState extends State<CatchTrash> {
  // Game variables
  int score = 0;
  int lifelines = 5;
  double baseFallSpeed = 3.0;
  bool gameOver = false;
  bool isPaused = false;
  String? hoveredBin;
  String? shakingBin;

  // Trash types and their correct bins
  final List<String> trashTypes = [
    'reusable',
    'recyclable',
    'biodegradable',
    'non-recyclable',
  ];
  final Map<String, String> binImages = {
    'reusable': 'assets/images/reusable_bin.png',
    'recyclable': 'assets/images/recyclable_bin.png',
    'biodegradable': 'assets/images/biodegradable_bin.png',
    'non-recyclable': 'assets/images/non_recyclable_bin.png',
  };
  final Map<String, List<String>> trashImages = {
    'reusable': [
      'assets/game/shirt.png',
      'assets/game/pants.png',
      'assets/game/shoes.png',
      'assets/game/glass_bottle_1.png',
      'assets/game/socks.png',
    ],
    'recyclable': [
      'assets/game/glass_bottle_1.png',
      'assets/game/cardboard_1.png',
      'assets/game/cardboard_2.png',
      'assets/game/plastic_bottle_1.png',
      'assets/game/plastic_bottle_2.png',
      'assets/game/can_1.png',
      'assets/game/soda_can_1.png',
      'assets/game/soda_can_2.png',
      'assets/game/soda_can_3.png',
      'assets/game/paper_1.png',
      'assets/game/paper_2.png',
      'assets/game/plastic_cup_1.png',
      'assets/game/plastic_cup_2.png',
      'assets/game/straw_1.png',
      'assets/game/toilet_paper.png',
      'assets/game/plastic_1.png',
      'assets/game/plastic_2.png',
    ],
    'biodegradable': [
      'assets/game/apple_trash.png',
      'assets/game/banana_peel.png',
      'assets/game/chicken_trash.png',
      'assets/game/egg_shell_1.png',
      'assets/game/egg_shell_2.png',
      'assets/game/pizza_trash.png',
      'assets/game/watermelon_trash.png',
    ],
    'non-recyclable': [
      'assets/game/battery.png',
      'assets/game/diaper.png',
      'assets/game/mask.png',
      'assets/game/toothbrush.png',
    ],
  };

  // Falling trash list
  List<TrashItem> fallingTrash = [];
  Timer? gameTimer;
  Timer? spawnTimer; // Added to manage spawning separately

  // Bin positions (will be set in build)
  Map<String, Rect> binRects = {};
  double bodyWidth = 0; // To store body width for spawning
  double bodyHeight = 0; // To store body height for checking bottom collision

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    score = 0;
    lifelines = 5;
    gameOver = false;
    fallingTrash.clear();
    gameTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      updateGame();
    });
    spawnTrash();
  }

  void pauseGame() {
    if (isPaused) return;
    isPaused = true;
    gameTimer?.cancel();
    spawnTimer?.cancel();
    setState(() {});
  }

  void resumeGame() {
    if (!isPaused) return;
    isPaused = false;

    gameTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      updateGame();
    });

    spawnTrash();
    setState(() {});
  }

  void spawnTrash() {
    spawnTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (gameOver) timer.cancel();
      if (!gameOver && bodyWidth > 0) {
        final randomType = trashTypes[Random().nextInt(trashTypes.length)];
        final images = trashImages[randomType]!;
        final randomImage = images[Random().nextInt(images.length)];

        fallingTrash.add(
          TrashItem(
            type: randomType,
            imagePath: randomImage,
            x: Random().nextDouble() * (bodyWidth - 50),
            y: 0,
          ),
        );
      }
    });
  }

  double getFallSpeed() {
    // Every 25 score adds +0.5 speed
    int increments = score ~/ 25; // integer division
    return baseFallSpeed + (increments * 0.5);
  }

  void updateGame() {
    setState(() {
      if (isPaused) return;

      // Move trash down
      for (var trash in fallingTrash) {
        if (!trash.isBeingDragged) {
          trash.y += getFallSpeed(); // Speed
        }
      }

      // Check if trash reached bottom (using body height)
      fallingTrash.removeWhere((trash) {
        if (!trash.isBeingDragged && trash.y > bodyHeight - 100) {
          lifelines--;
          if (lifelines <= 0) {
            gameOver = true;
            gameTimer?.cancel();
            spawnTimer?.cancel();
          }
          return true;
        }
        return false;
      });
    });
  }

  void onDragEnd(TrashItem trash, Offset position) {
    if (!fallingTrash.contains(trash)) return;

    // Check if dropped on correct bin
    final correctBin = trash.type;
    if (binRects[correctBin]!.contains(position)) {
      setState(() {
        score++;
        fallingTrash.remove(trash);
      });
      return;
    }

    // Check if dropped on any bin
    for (final entry in binRects.entries) {
      final binType = entry.key;
      final rect = entry.value;

      if (rect.contains(position)) {
        if (binType == trash.type) {
          // ✅ Correct bin
          setState(() {
            score++;
            fallingTrash.remove(trash);
          });
          return;
        } else {
          // ❌ Wrong bin → shake
          setState(() {
            shakingBin = binType;
          });

          Future.delayed(const Duration(milliseconds: 400), () {
            if (mounted) {
              setState(() => shakingBin = null);
            }
          });

          break;
        }
      }
    }

    // Wrong bin or anywhere else → snap back, no penalty
    setState(() {
      trash.x = trash.startX;
      trash.y = trash.startY;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Catch the Trash')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bodyWidth = constraints.maxWidth; // Set bodyWidth
          bodyHeight = constraints.maxHeight;

          // Update binRects based on actual body constraints
          for (int i = 0; i < trashTypes.length; i++) {
            final type = trashTypes[i];
            binRects[type] = Rect.fromLTWH(
              (constraints.maxWidth / 4) * i,
              constraints.maxHeight - 370,
              constraints.maxWidth / 4,
              100,
            );
          }

          return Stack(
            children: [
              // Background image
              Positioned.fill(
                child: Image.asset(
                  'assets/game/river_bank.gif',
                  fit: BoxFit.cover,
                ),
              ),

              // UI Overlay
              Positioned(
                top: 25,
                right: 13,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xffc3deac).withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xff7baf31),
                        blurRadius: 6,
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      buildScore(),
                      const SizedBox(width: 15),
                      buildLives(),
                      const SizedBox(width: 15),

                      // Pause / Resume button
                      GestureDetector(
                        onTap: () {
                          if (isPaused) {
                            resumeGame();
                          } else {
                            pauseGame();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPaused
                                ? Icons.play_arrow_rounded
                                : Icons.pause_rounded,
                            color: Colors.white,
                            size: 23,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bins
              Positioned(
                bottom: 270,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: trashTypes.map((type) {
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: shakingBin == type ? 1 : 0),
                      duration: const Duration(milliseconds: 400),
                      builder: (context, value, child) {
                        final shakeOffset = sin(value * pi * 6) * 6;
                        return Transform.translate(
                          offset: Offset(shakeOffset, 0),
                          child: child,
                        );
                      },
                      child: AnimatedScale(
                        scale: hoveredBin == type ? 1.1 : 1.0,
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOut,
                        child: Image.asset(
                          binImages[type]!,
                          width: constraints.maxWidth / 4,
                          height: 100,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Falling trash
              ...fallingTrash.map(
                (trash) => Positioned(
                  left: trash.x,
                  top: trash.y,
                  child: GestureDetector(
                    onPanStart: (_) {
                      trash.isBeingDragged = true;
                      trash.startX = trash.x;
                      trash.startY = trash.y;
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        trash.x += details.delta.dx;
                        trash.y += details.delta.dy;

                        hoveredBin = null;
                        final center = Offset(trash.x + 25, trash.y + 25);

                        for (final entry in binRects.entries) {
                          if (entry.value.contains(center)) {
                            hoveredBin = entry.key;
                            break;
                          }
                        }
                      });
                    },
                    onPanEnd: (details) {
                      trash.isBeingDragged = false;
                      hoveredBin = null;
                      onDragEnd(
                        trash,
                        Offset(trash.x + 25, trash.y + 25),
                      ); // Approximate center
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        trash.imagePath,
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ),
                ),
              ),

              if (gameOver) ...[
                // Dark background overlay
                Positioned.fill(
                  child: Container(color: Colors.black.withOpacity(0.6)),
                ),

                // Game Over Dialog
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xfff3f8ef),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Image
                        Image.asset(
                          'assets/game/game_over_ct.png',
                          height: 120,
                        ),

                        const SizedBox(height: 12),

                        // Title
                        const Text(
                          'Game Over',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff7baf31),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Score
                        Text(
                          'You\'ve Earned: $score Stars',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Home Button
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.home_rounded),
                              label: const Text('Home'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),

                            // Restart Button
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  gameOver = false;
                                  isPaused = false;
                                });
                                startGame();
                              },
                              icon: const Icon(Icons.replay_rounded),
                              label: const Text('Restart'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff7baf31),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Back button
              Positioned(
                top: 19,
                left: 2,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_circle_left_rounded,
                    color: Color(0xff7baf31),
                    size: 45,
                  ),
                  onPressed: () {
                    showQuitDialog();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildScore() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rate_rounded, color: Color(0xfff1da06), size: 25),

        Text(
          score.toString(),
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget buildLives() {
    return Row(
      children: List.generate(5, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Icon(
            index < lifelines ? Icons.favorite : Icons.heart_broken_outlined,
            color: Color(0xffda2756),
            size: 25,
          ),
        );
      }),
    );
  }

  Future<void> showQuitDialog() async {
    pauseGame();

    final shouldQuit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Quit Game?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Are you sure you want to quit the game?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffda2756),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Quit', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );

    if (shouldQuit == true && mounted) {
      Navigator.of(context).pop();
    } else {
      resumeGame();
    }
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    spawnTimer?.cancel();
    super.dispose();
  }
}

class TrashItem {
  String type;
  String imagePath;
  double x;
  double y;
  double startX;
  double startY;
  bool isBeingDragged;

  TrashItem({
    required this.type,
    required this.imagePath,
    required this.x,
    required this.y,
    this.isBeingDragged = false,
  }) : startX = x,
       startY = y;
}
