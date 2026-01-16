import 'package:flutter/material.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text(
          "Next: camera/gallery + TFLite prediction",
          textAlign: TextAlign.center,
        ),
      )
    );
  }
}