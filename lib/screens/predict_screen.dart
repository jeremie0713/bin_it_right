import 'package:flutter/material.dart';

class PredictScreen extends StatelessWidget {
  const PredictScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            "Prediction screen (Camera/Gallery)\nTFLite comes next ✅",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}
