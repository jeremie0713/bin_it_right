import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CleanTheParkGame extends StatefulWidget {
  const CleanTheParkGame({super.key});

  @override
  State<CleanTheParkGame> createState() => _CleanTheParkGameState();
}

class _CleanTheParkGameState extends State<CleanTheParkGame> {
  int score = 0;
  int timeLeft = 120;
  bool gameOver = false;
  bool _gameStarted = false;

  bool isPaused = false;

  Timer? countdownTimer;
  List<FloatingScore> floatingScores = [];

  Rect scatterArea = Rect.zero;
  Rect binArea = Rect.zero;

  Map<String, Rect> binRects = {};
  String? shakingBin;
  String? hoveredBin;

  List<TrashItem> trashItems = [];

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
      'assets/game/backpack.png',
      'assets/game/tumbler_bottle.png',
      'assets/game/food_container.png',
      'assets/game/old_books.png',
      'assets/game/old_toy_car.png'

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
      'assets/game/toilet_paper_core.png',
      'assets/game/plastic_1.png',
      'assets/game/plastic_2.png',
      'assets/game/milk_carton.png',
      'assets/game/shampoo_bottle.png',
      'assets/game/detergent_bottle.png',
      'assets/game/glass_jar.png'
    ],
    'biodegradable': [
      'assets/game/apple_core.png',
      'assets/game/banana_peel.png',
      'assets/game/chicken_leftover.png',
      'assets/game/egg_shell_1.png',
      'assets/game/egg_shell_2.png',
      'assets/game/pizza_leftover.png',
      'assets/game/watermelon_peel.png',
      'assets/game/moldy_bread.png',
      'assets/game/fish_bone.png',
      'assets/game/tea_bag.png'
    ],
    'non-recyclable': [
      'assets/game/battery.png',
      'assets/game/diaper_1.png',
      'assets/game/diaper_2.png',
      'assets/game/mask.png',
      'assets/game/toothbrush_trash.png',
      'assets/game/dirty_gloves.png',
      'assets/game/dirty_towel.png'
    ],
  };

  @override
  void initState() {
    super.initState();
  }

  void startGame() {
    score = 0;
    timeLeft = 120;
    gameOver = false;

    trashItems.clear(); // clear old trash
    spawnAllTrash(); // spawn once here

    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          gameOver = true;
          timer.cancel();
        }
      });
    });

    setState(() {});
  }

  Future<bool> _showExitDialog() async {
    countdownTimer?.cancel();

    bool shouldExit =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
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
          ),
        ) ??
        false;

    // If user pressed NO, resume timer
    if (!shouldExit && timeLeft > 0 && !gameOver && !isPaused) {
      countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (timeLeft > 0) {
            timeLeft--;
          } else {
            gameOver = true;
            timer.cancel();
          }
        });
      });
    }

    return shouldExit;
  }

  void pauseGame() {
    if (isPaused) return;

    setState(() {
      isPaused = true;
    });

    countdownTimer?.cancel(); // ⏸ stop timer
  }

  void resumeGame() {
    if (!isPaused) return;

    setState(() {
      isPaused = false;
    });

    // resume timer only if game not over
    if (!gameOver && timeLeft > 0) {
      countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (timeLeft > 0) {
            timeLeft--;
          } else {
            gameOver = true;
            timer.cancel();
          }
        });
      });
    }
  }

  void spawnAllTrash() {
    List<TrashItem> newTrash = [];

    trashImages.forEach((type, images) {
      for (var image in images) {
        newTrash.add(TrashItem(type: type, imagePath: image, x: 0, y: 0));
      }
    });

    newTrash.shuffle();

    for (var trash in newTrash) {
      Offset pos;
      int attempts = 0;

      do {
        pos = getRandomPosition();
        attempts++;
      } while (newTrash.any(
            (t) =>
                t != trash &&
                (t.x - pos.dx).abs() < 50 &&
                (t.y - pos.dy).abs() < 50,
          ) &&
          attempts < 50);

      trash.x = pos.dx;
      trash.y = pos.dy;
      trash.startX = pos.dx;
      trash.startY = pos.dy;
    }

    setState(() {
      trashItems = newTrash;
    });
  }

  Offset getRandomPosition() {
    if (scatterArea.width <= 0 || scatterArea.height <= 0) {
      return const Offset(200, 200);
    }

    final random = Random();
    double x =
        scatterArea.left + random.nextDouble() * (scatterArea.width - 50);
    double y =
        scatterArea.top + random.nextDouble() * (scatterArea.height - 50);

    return Offset(x, y);
  }

  void checkAllTrashSorted() {
    if (trashItems.isEmpty && timeLeft > 0) {
      // respawn all trash randomly
      spawnAllTrash();
    }
  }

  void onDragEnd(TrashItem trash, Offset position) {
    for (final entry in binRects.entries) {
      if (entry.value.contains(position)) {
        final binType = entry.key;
        final binRect = entry.value;

        if (binType == trash.type) {
          // SNAP TO BIN CENTER
          setState(() {
            trash.snapping = true;
            trash.x = binRect.center.dx - 25;
            trash.y = binRect.center.dy - 25;
          });

          // ADD FLOATING +1
          floatingScores.add(
            FloatingScore(x: binRect.center.dx, y: binRect.top - 10),
          );

          // remove floating score after animation
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted && floatingScores.isNotEmpty) {
              setState(() {
                floatingScores.removeAt(0);
              });
            }
          });

          // remove trash after snap
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              setState(() {
                score++;
                trashItems.remove(trash);
              });

              // ✅ check if all trash sorted
              checkAllTrashSorted();
            }
          });

          return;
        } else {
          // WRONG BIN → SHAKE + RETURN TO START
          setState(() {
            shakingBin = binType;
            trash.x = trash.startX;
            trash.y = trash.startY;
          });

          Future.delayed(const Duration(milliseconds: 400), () {
            if (mounted) setState(() => shakingBin = null);
          });

          return;
        }
      }
    }

    // NOT DROPPED ON ANY BIN → RETURN TO START
    setState(() {
      trash.x = trash.startX;
      trash.y = trash.startY;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _showExitDialog();
      },
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;

            binArea = Rect.fromLTRB(
              0,
              screenHeight * 0.75,
              screenWidth,
              screenHeight,
            );

            scatterArea = Rect.fromLTRB(
              screenWidth * 0.02, // 🔹 more left
              screenHeight * 0.42, // 🔹 higher start
              screenWidth * 0.98, // 🔹 more right
              screenHeight * 0.80, // 🔹 taller area (but still above bins)
            );

            final binWidth = screenWidth * 0.22;
            final binHeight = screenHeight * 0.16;

            final spacing = screenWidth * 0.03;

            // total width of all bins + spacing
            final totalWidth =
                (binWidth * trashTypes.length) +
                (spacing * (trashTypes.length - 1));

            // center horizontally
            final startX = (screenWidth - totalWidth) / 2;

            // place near bottom
            final top = screenHeight * 0.85;

            binRects.clear();

            for (int i = 0; i < trashTypes.length; i++) {
              final left = startX + i * (binWidth + spacing);

              binRects[trashTypes[i]] = Rect.fromLTWH(
                left,
                top,
                binWidth,
                binHeight,
              );
            }

            if (!_gameStarted &&
                scatterArea.width > 0 &&
                scatterArea.height > 0) {
              _gameStarted = true;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  startGame();
                }
              });
            }

            return Stack(
              children: [
                Positioned.fill(
                  child: Image.asset('assets/images/yard.gif', fit: BoxFit.cover),
                ),

                // TIMER + SCORE
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
                        Text(
                          "Time: ${timeLeft ~/ 60}:${(timeLeft % 60).toString().padLeft(2, '0')}",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          "Score: $score",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.yellow,
                          ),
                        ),
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

                // BINS
                ...trashTypes.map((type) {
                  final rect = binRects[type];
                  if (rect == null) return const SizedBox.shrink();

                  final isHovered = hoveredBin == type;
                  final isShaking = shakingBin == type;

                  return Positioned(
                    left: rect.left,
                    top: rect.top,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: isShaking ? 1 : 0),
                      duration: const Duration(milliseconds: 300),
                      builder: (context, value, child) {
                        // 🔹 Shake animation (left-right)
                        final shakeOffset = sin(value * pi * 6) * 6;

                        return Transform.translate(
                          offset: Offset(shakeOffset, 0),
                          child: AnimatedScale(
                            scale: isHovered
                                ? 1.15
                                : 1.0, // 🔹 bin grows on hover
                            duration: const Duration(milliseconds: 150),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                boxShadow: isHovered
                                    ? [
                                        BoxShadow(
                                          color: Colors.yellow.withOpacity(0.8),
                                          blurRadius: 20,
                                          spreadRadius: 3,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: Image.asset(
                        binImages[type]!,
                        width: rect.width,
                        height: rect.height,
                      ),
                    ),
                  );
                }),

                // TRASH ITEMS
                ...trashItems.map(
                  (trash) => AnimatedPositioned(
                    key: ValueKey(trash.hashCode),
                    duration: Duration(milliseconds: trash.snapping ? 300 : 0),
                    left: trash.x,
                    top: trash.y,
                    child: GestureDetector(
                      onPanStart: isPaused
                          ? null
                          : (_) {
                              setState(() {
                                trash.isDragging = true;
                                trash.startX = trash.x;
                                trash.startY = trash.y;

                                // 🔹 bring dragged trash to front safely
                                trashItems.remove(trash);
                                trashItems.add(trash);
                              });
                            },

                      onPanUpdate: isPaused
                          ? null
                          : (details) {
                              setState(() {
                                trash.x += details.delta.dx;
                                trash.y += details.delta.dy;

                                hoveredBin = null;
                                final trashCenter = Offset(
                                  trash.x + 25,
                                  trash.y + 25,
                                );

                                for (final entry in binRects.entries) {
                                  if (entry.value.contains(trashCenter)) {
                                    hoveredBin = entry.key;
                                    break;
                                  }
                                }
                              });
                            },

                      onPanEnd: isPaused
                          ? null
                          : (_) {
                              setState(() {
                                hoveredBin = null;
                                trash.isDragging = false;
                              });
                              onDragEnd(
                                trash,
                                Offset(trash.x + 25, trash.y + 25),
                              );
                            },

                      child: AnimatedScale(
                        scale: trash.isDragging ? 1.15 : 1.0,
                        duration: const Duration(milliseconds: 120),
                        child: Image.asset(
                          trash.imagePath,
                          width: 50,
                          height: 50,
                        ),
                      ),
                    ),
                  ),
                ),

                // ⭐ FLOATING +1 SCORE POPUPS
                ...floatingScores.map((fs) {
                  return Positioned(
                    left: fs.x,
                    top: fs.y,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: 1 - value,
                          child: Transform.translate(
                            offset: Offset(0, -30 * value), // 🔹 float upward
                            child: child,
                          ),
                        );
                      },
                      child: const Text(
                        "+1 ⭐",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                        ),
                      ),
                    ),
                  );
                }),

                // ⏸ PAUSE OVERLAY WITH PLAY BUTTON
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

                if (gameOver)
                  // Game Over Dialog
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.6),
                      child: Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
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
                                'assets/images/great Job.gif',
                                height: 120,
                              ),

                              const SizedBox(height: 5),

                              // Score
                              Text(
                                "Time's Up!\nGreat Job!\n You've Earned: $score Stars",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Buttons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                                        countdownTimer?.cancel();
                                        _gameStarted = false;
                                        startGame();
                                      });
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
                    ),
                  ),

                // Back button
                Positioned(
                  top: 22,
                  left: 19,
                  child: GestureDetector(
                    onTap: () async {
                      bool exit =
                          await _showExitDialog(); // ✅ wait for dialog result
                      if (exit) {
                        Navigator.of(context).pop();
                      }
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

  @override
  void dispose() {
    countdownTimer?.cancel();

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
  bool snapping = false;
  bool isDragging = false;

  TrashItem({
    required this.type,
    required this.imagePath,
    required this.x,
    required this.y,
  }) : startX = x,
       startY = y;
}

class FloatingScore {
  double x;
  double y;

  FloatingScore({required this.x, required this.y});
}
