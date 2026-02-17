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
  TrashItem? activeDrag;

  bool gameOver = false;
  bool isPaused = false;
  String? hoveredBin;
  String? shakingBin;
  List<FloatingStar> floatingStars = [];

  // Trash types and their correct bins
  final List<String> trashTypes = [
    'reusable',
    'recyclable',
    'biodegradable',
    'non-recyclable',
  ];
  final Map<String, String> binImages = {
    'reusable': 'assets/game/reusable_bin.png',
    'recyclable': 'assets/game/recyclable_bin.png',
    'biodegradable': 'assets/game/biodegradable_bin.png',
    'non-recyclable': 'assets/game/non_recyclable_bin.png',
  };
  final Map<String, List<String>> trashImages = {
    'reusable': [
      'assets/game/shirt.png',
      'assets/game/pants.png',
      'assets/game/shoes.png',
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
        if (!trash.isBeingDragged && !trash.isSnapping) {
          trash.y += getFallSpeed();
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
      });

      snapToBin(trash, binRects[correctBin]!);
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
          });
          snapToBin(trash, rect);
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

  void showFloatingStar(double x, double y) {
    final star = FloatingStar(x: x, y: y);

    setState(() => floatingStars.add(star));

    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        star.y -= 4;
        star.opacity -= 0.05;
      });

      if (star.opacity <= 0) {
        floatingStars.remove(star);
        timer.cancel();
      }
    });
  }

  void snapToBin(TrashItem trash, Rect binRect) {
    trash.isSnapping = true;

    trash.snapTargetX = binRect.center.dx - 25;
    trash.snapTargetY = binRect.top - 20;

    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted || !fallingTrash.contains(trash)) {
        timer.cancel();
        return;
      }

      setState(() {
        final dx = trash.snapTargetX! - trash.x;
        final dy = trash.snapTargetY! - trash.y;

        trash.x += dx * 0.2;
        trash.y += dy * 0.2;
        trash.opacity -= 0.05;
      });

      if (trash.opacity <= 0) {
        showFloatingStar(trash.x, trash.y);
        fallingTrash.remove(trash);
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await showQuitDialog();
        return false; // prevent auto pop
      },
      child: Scaffold(
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
                  top: 22,
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
                    key: ValueKey(trash.id),
                    left: trash.x,
                    top: trash.y,
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanStart: activeDrag == null
                            ? (_) {
                                activeDrag = trash;

                                fallingTrash.remove(trash);
                                fallingTrash.add(trash);

                                trash.isBeingDragged = true;
                                trash.isSnapping = false;
                                trash.opacity = 1.0;

                                trash.startX = trash.x;
                                trash.startY = trash.y;
                              }
                            : null,
                        onPanUpdate: (details) {
                          if (activeDrag != trash) return;

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
                        onPanEnd: (_) {
                          if (activeDrag != trash) return;

                          trash.isBeingDragged = false;
                          hoveredBin = null;
                          onDragEnd(trash, Offset(trash.x + 25, trash.y + 25));

                          activeDrag = null;
                        },
                        child: Opacity(
                          opacity: trash.opacity,
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
                  ),
                ),

                ...floatingStars.map(
                  (star) => Positioned(
                    left: star.x,
                    top: star.y,
                    child: Opacity(
                      opacity: star.opacity,
                      child: Row(
                        children: const [
                          Icon(
                            Icons.star_rate_rounded,
                            color: Color(0xfff1da06),
                            size: 24,
                          ),
                          SizedBox(width: 2),
                          Text(
                            "+1",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
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
                            'assets/game/great Job.gif',
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

                if (isPaused && !gameOver)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: GestureDetector(
                          onTap: resumeGame, // resume when tapped
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 150),
                            scale: 1.0,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: const BoxDecoration(
                                color: Color(0xff7baf31),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black45,
                                    blurRadius: 15,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                size: 70,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Back button
                Positioned(
                  top: 19,
                  left: 2,
                  child: GestureDetector(
                    onTap: () async {
                      await showQuitDialog();
                    },
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xff7baf31),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              0.45,
                            ), // softer shadow
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded, // cleaner arrow
                        color: Colors.white, // ✅ visible now
                        size: 26, // fits inside circle
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
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
            title: const Text("Quit Game?"),
            content: const Text("Are you sure you want to quit the game?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Yes"),
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
  bool isSnapping;
  double? snapTargetX;
  double? snapTargetY;
  double opacity;
  final String id = UniqueKey().toString();

  TrashItem({
    required this.type,
    required this.imagePath,
    required this.x,
    required this.y,
    this.isBeingDragged = false,
    this.isSnapping = false,
    this.snapTargetX,
    this.snapTargetY,
    this.opacity = 1.0,
  }) : startX = x,
       startY = y;
}

class FloatingStar {
  double x;
  double y;
  double opacity = 1.0;

  FloatingStar({required this.x, required this.y});
}
