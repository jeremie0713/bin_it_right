import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GameSortScreen extends StatefulWidget {
  const GameSortScreen({super.key});

  @override
  State<GameSortScreen> createState() => _GameSortScreenState();
}

class _GameSortScreenState extends State<GameSortScreen> {
  @override
  void initState() {
    super.initState();
    // Force landscape for this screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Back to portrait when leaving games
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            "Drag & Drop Sorting Game (Landscape)\nWe’ll build this next ✅",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}
