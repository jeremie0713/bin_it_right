import 'dart:async';
import 'package:bin_it_right/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  double opacity = 0;
  double translateY = 40;
  double buttonScale = 1;

  int activeStep = 0;
  Timer? stepTimer;
  Timer? buttonTimer;

  bool showButtons = false;
  bool isFirstRun = true;

  final steps = [
    {"icon": Icons.camera_alt, "label": "Snap"},
    {"icon": Icons.psychology, "label": "Learn"},
    {"icon": Icons.delete, "label": "Sort"},
  ];

  @override
  void initState() {
    super.initState();
    _checkFirstRun();

    /// Entrance animation
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        opacity = 1;
        translateY = 0;
      });
    });

    /// Bouncing guide icons loop
    stepTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      setState(() {
        activeStep = (activeStep + 1) % steps.length;
      });
    });

    /// Pulsing button animation
    buttonTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      setState(() => buttonScale = 1.08);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => buttonScale = 1);
      });
    });
  }

  Future<void> _checkFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool("seen_onboarding") ?? false;

    if (hasSeenOnboarding) {
      /// Not first run → show buttons immediately
      setState(() {
        isFirstRun = false;
        showButtons = true;
      });
    } else {
      /// First run → wait 12 seconds (GIF duration)
      Future.delayed(const Duration(seconds: 12), () {
        if (!mounted) return;
        setState(() => showButtons = true);
      });

      await prefs.setBool("seen_onboarding", true);
    }
  }

  @override
  void dispose() {
    stepTimer?.cancel();
    buttonTimer?.cancel();
    super.dispose();
  }

  void goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f5d9),
      body: SafeArea(
        child: Stack(
          children: [
            /// Skip button (only when allowed)
            if (showButtons)
              Positioned(
                top: 10,
                right: 16,
                child: TextButton(
                  onPressed: goToHome,
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            /// Main Content
            Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 600),
                opacity: opacity,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  transform: Matrix4.translationValues(0, translateY, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/onboarding/onboarding_demo.gif",
                        height: 300,
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        "🌍 Let’s Sort Trash!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        "Take a picture of your trash.\nWe will tell you what it is and which bin to use!",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),

                      const SizedBox(height: 30),

                      /// Guide Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(steps.length, (index) {
                          final isActive = index == activeStep;

                          return AnimatedScale(
                            duration: const Duration(milliseconds: 300),
                            scale: isActive ? 1.2 : 1.0,
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.green
                                    : Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    steps[index]["icon"] as IconData,
                                    color: isActive
                                        ? Colors.white
                                        : Colors.green,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    steps[index]["label"] as String,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isActive
                                          ? Colors.white
                                          : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 40),

                      /// Let’s Start Button (only when allowed)
                      if (showButtons)
                        AnimatedScale(
                          duration: const Duration(milliseconds: 300),
                          scale: buttonScale,
                          child: ElevatedButton(
                            onPressed: goToHome,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 36,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              "Let’s Start!",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
