import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WhatBinQuizGame extends StatefulWidget {
  const WhatBinQuizGame({super.key});

  @override
  State<WhatBinQuizGame> createState() => _WhatBinQuizGameState();
}

class _WhatBinQuizGameState extends State<WhatBinQuizGame> {
  List<QuizItem> questions = [];
  int currentIndex = 0;
  int score = 0;

  int timeLimit = 20;
  int remainingTime = 20;

  Timer? timer;
  bool isGameOver = false;

  bool showGameOverOverlay = false;
  bool showStar = false;

  final List<String> bins = [
    "Non-Recyclable",
    "Biodegradable",
    "Reusable",
    "Recyclable",
  ];

  @override
  void initState() {
    super.initState();
    loadQuizItems();
  }

  /// 📦 LOAD JSON
  Future<void> loadQuizItems() async {
    final String data = await rootBundle.loadString(
      'assets/data/quiz_questions.json',
    );
    final List<dynamic> jsonResult = json.decode(data);

    questions = jsonResult.map((e) => QuizItem.fromJson(e)).toList();
    questions.shuffle(Random());

    setState(() {});
    startInstructionDialog();
  }

  /// 📘 START DIALOG
  void startInstructionDialog() {
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("How to play"),
          content: const Text("You have 20 seconds to answer each question."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                startTimer();
              },
              child: const Text("Start"),
            ),
          ],
        ),
      );
    });
  }

  /// ⏱ TIMER
  void startTimer() {
    remainingTime = timeLimit;
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        remainingTime--;
        if (remainingTime <= 0) gameOver();
      });
    });
  }

  /// 🔁 NEXT QUESTION
  void nextQuestion() {
    currentIndex++;

    if (currentIndex >= questions.length) {
      questions.shuffle();
      currentIndex = 0;
    }

    bool dialogShown = adjustDifficulty();

    if (!dialogShown) {
      startTimer();
    }
  }

  /// 🎯 DIFFICULTY SCALING
  bool adjustDifficulty() {
    if (score >= 150 && timeLimit != 5) {
      timeLimit = 5;
      showDifficultyDialog("⚠ Super fast! You now have 5 seconds!");
      return true;
    } else if (score >= 100 && timeLimit != 10) {
      timeLimit = 10;
      showDifficultyDialog("⚠ Time is now 10 seconds!");
      return true;
    } else if (score >= 75 && timeLimit != 13) {
      timeLimit = 13;
      showDifficultyDialog("⚠ Time is now 13 seconds!");
      return true;
    } else if (score >= 50 && timeLimit != 15) {
      timeLimit = 15;
      showDifficultyDialog("⚠ Time is now 15 seconds!");
      return true;
    } else if (score >= 25 && timeLimit != 18) {
      timeLimit = 18;
      showDifficultyDialog("⚠ Time is now 18 seconds!");
      return true;
    }

    return false;
  }

  void showDifficultyDialog(String message) {
    timer?.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("⚠️ Warning"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              startTimer(); // timer resumes ONLY after OK
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  /// ✅ CHECK ANSWER
  void checkAnswer(String selected) {
    if (isGameOver) return;

    final correct = questions[currentIndex].bin;

    if (selected == correct) {
      score++;

      // ⭐ show floating star
      setState(() {
        showStar = true;
      });

      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() => showStar = false);
          nextQuestion();
        }
      });
    } else {
      setState(() {
        remainingTime -= 1;
        if (remainingTime <= 0) gameOver();
      });
    }
  }

  //Exit Confirmation
  Future<bool> showExitDialog() async {
    timer?.cancel();

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Quit Game?"),
        content: const Text("Are you sure you want to quit the game?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
              startTimer(); // resume if cancelled
            },
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    return shouldExit ?? false;
  }

  /// GAME OVER
  void gameOver() {
    timer?.cancel();
    setState(() {
      isGameOver = true;
      showGameOverOverlay = true;
    });
  }

  void restartGame() {
    setState(() {
      score = 0;
      currentIndex = 0;
      timeLimit = 20;
      isGameOver = false;
      questions.shuffle();
    });

    startTimer();
  }

  double get progress => remainingTime / timeLimit;

  /// 🎨 BIN BUTTON STYLE
  Color getBinColor(String bin) {
    switch (bin) {
      case "Non-Recyclable":
        return const Color(0xFFff4f63);
      case "Biodegradable":
        return Colors.green;
      case "Reusable":
        return Colors.yellow;
      case "Recyclable":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Stars: $score"),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: showHelpDialog,
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          return await showExitDialog();
        },
        child: Stack(
          children: [
            Column(
              children: [
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.grey[300],
                  color: progress > 0.3 ? Colors.green : Colors.red,
                ),

                const SizedBox(height: 20),

                Image.asset(questions[currentIndex].image, height: 180),

                const SizedBox(height: 10),

                Text(
                  questions[currentIndex].label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "Which bin does this belong to?",
                  style: TextStyle(fontSize: 20, color: Colors.grey[800]),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: bins.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 2.8,
                        ),
                    itemBuilder: (_, i) {
                      final bin = bins[i];

                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: getBinColor(bin),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => checkAnswer(bin),
                        child: Text(
                          bin,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            /// ⭐ FLOATING STAR
            if (showStar)
              Positioned.fill(
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 700),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, -150 * value),
                        child: Opacity(
                          opacity: 1 - value,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rate_rounded,
                                color: Color(0xfff1da06),
                                size: 80,
                              ),

                              Text(
                                "+1",
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            /// 💀 GAME OVER OVERLAY
            if (showGameOverOverlay)
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
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/great Job.gif',
                            height: 120,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Time's Up!\nGreat Job!\nYou've Earned: $score ⭐",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.home),
                                label: const Text("Home"),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    showGameOverOverlay = false;
                                    restartGame();
                                  });
                                },
                                icon: const Icon(Icons.replay),
                                label: const Text("Restart"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// ❓ HELP DIALOG
  void showHelpDialog() {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text("How to Play"),
        content: Text(
          "• You have limited time to answer\n"
          "• Wrong answer time is reduced by 1 second\n"
          "• When your score reaches 25 → time becomes 18 seconds\n"
          "• When your score reaches 50 → time becomes 15 seconds\n"
          "• When your score reaches 75 → time becomes 13 seconds\n"
          "• When your score reaches 100 → time becomes 10 seconds\n"
          "• When your score reaches 150+ → time becomes 5 seconds\n",
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}

/// 📦 MODEL
class QuizItem {
  final String image;
  final String label;
  final String bin;
  final String category;

  QuizItem({
    required this.image,
    required this.label,
    required this.bin,
    required this.category,
  });

  factory QuizItem.fromJson(Map<String, dynamic> json) {
    return QuizItem(
      image: json['image'],
      label: json['label'],
      bin: json['bin'],
      category: json['category'],
    );
  }
}
