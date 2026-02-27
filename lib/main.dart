import 'package:bin_it_right/screens/home_screen.dart';
import 'package:bin_it_right/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;

  runApp(BinItRightApp(seenOnboarding: seenOnboarding));
}

class BinItRightApp extends StatelessWidget {
  final bool seenOnboarding;

  const BinItRightApp({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bin It Right!',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.fredokaTextTheme(),
      ),
      home: seenOnboarding
          ? const HomeScreen()
          : const OnboardingScreen(),
    );
  }
}