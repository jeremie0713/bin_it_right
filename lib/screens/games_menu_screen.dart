import 'package:flutter/material.dart';
import 'game_sort_screen.dart';

class GamesMenuScreen extends StatelessWidget {
  const GamesMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                "Fun Games",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView(
                  children: [
                    _GameCard(
                      title: "Sort the Trash!",
                      subtitle: "Drag items to the correct bin",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const GameSortScreen()),
                        );
                      },
                    ),
                    _GameCard(
                      title: "Bin Quiz",
                      subtitle: "Pick the right bin (fast!)",
                      onTap: () {},
                    ),
                    _GameCard(
                      title: "Clean the Beach",
                      subtitle: "Time challenge clean-up",
                      onTap: () {},
                    ),
                    _GameCard(
                      title: "Recycle Match",
                      subtitle: "Match item → correct category",
                      onTap: () {},
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

class _GameCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFCAE7A2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF7CB342), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
