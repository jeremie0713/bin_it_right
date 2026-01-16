// import 'package:bin_it_right/screens/games_screen.dart';
// import 'package:bin_it_right/theme/app_theme.dart';
// import 'package:flutter/material.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             const SizedBox(height: 32),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: AppTheme.card,
//                 borderRadius: BorderRadius.circular(24),
//                 boxShadow: const [
//                   BoxShadow(
//                     blurRadius: 12,
//                     offset: Offset(0, 6),
//                     color: Color(0x22000000)
//                   )
//                 ]
//               ),
//               child: const Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Learn where trash goes",
//                     style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
//                     ),
//                     SizedBox(height: 6),
//                     Text(
//                       "Scan an item or play sorting games.",
//                       style: TextStyle(fontSize: 16),
//                     )
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),

//             _BigActionButton(
//               title: "Fun Sorting Games",
//               subtitle: "Test your recycling skills",
//               icon: Icons.videogame_asset,
//               color: AppTheme.accent,
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const GamesScreen()),
//                 );
//               },
//             ),

//             const Spacer(),
//             const Text(
//               "♻️ Recycle • 🌿 Biodegradable • 🗑️ Non-recyclable • 🔁 Reusable",
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 12),
//           ],
//         )
//       ),
//     );
//   }
// }

// class _BigActionButton extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final IconData icon;
//   final Color color;
//   final VoidCallback onTap;

//   const _BigActionButton({
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//     required this.color,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(24),
//       onTap: onTap,
//       child: Ink(
//         width: double.infinity,
//         padding: const EdgeInsets.all(18),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(24),
//           boxShadow: const [
//             BoxShadow(
//               blurRadius: 12,
//               offset: Offset(0, 6),
//               color: Color(0x22000000)
//             )
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.35),
//                 borderRadius: BorderRadius.circular(18),
//               ),
//               child: Icon(
//                 icon,
//                 size: 30,
//                 color: const Color(0xFF1F2D1F),
//               ),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w900,
//                       color: Color(0xFF1F2D1F),
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     subtitle,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       color: Color(0xFF1F2D1F),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//             const Icon(
//               Icons.chevron_right_rounded,
//               size: 34,
//               color: Color(0xFF1F2D1F),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'predict_screen.dart';
import 'games_menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _leftCtrl;
  late final AnimationController _rightCtrl;

  @override
  void initState() {
    super.initState();

    _leftCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);

    _rightCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _leftCtrl.dispose();
    _rightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/home_bg.jpg'),
              fit: BoxFit.fill,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 200,
                right: 150,
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: AnimatedBuilder(
                    animation: _leftCtrl,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _leftCtrl.value * 2 * math.pi,
                        child: Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/sun.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Main content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 150,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 50,
                            top: 0,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/title.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          // GIF positioned at top right
                          Positioned(
                            right: 40,
                            top: 40,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/right.gif'),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: _BouncyTile(
                            controller: _leftCtrl,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PredictScreen(),
                                ),
                              );
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/scan_tile.gif'), // Your scan tile image
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _BouncyTile(
                            controller: _rightCtrl,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const GamesMenuScreen(),
                                ),
                              );
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/game_tile.gif'), // Your games tile image
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),
                    _LegendRow(),
                    const SizedBox(height: 8),
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

class _BouncyTile extends StatelessWidget {
  final AnimationController controller;
  final Widget child;
  final VoidCallback onTap;

  const _BouncyTile({
    required this.controller,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        // Smooth bounce using a sine wave
        final t = controller.value;
        final scale = 1.0 + (math.sin(t * math.pi) * 0.035); // bounce amount
        final dy = -math.sin(t * math.pi) * 6.0;

        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.scale(
            scale: scale,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                height: 170,
                decoration: BoxDecoration(
                  color: const Color(0xFFCAE7A2), // light green
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF7CB342), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 14,
                      offset: Offset(0, 8),
                      color: Color(0x22000000),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HomeTileContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;

  const _HomeTileContent({
    required this.title,
    required this.subtitle,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title $emoji",
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
        ),
        const Spacer(),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget dot(Color c) => Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    );

    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            dot(Colors.blue),
            const SizedBox(width: 6),
            const Text("Recyclable"),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            dot(Colors.green),
            const SizedBox(width: 6),
            const Text("Biodegradable"),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            dot(Colors.red),
            const SizedBox(width: 6),
            const Text("Non-recyclable"),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            dot(Colors.yellow),
            const SizedBox(width: 6),
            const Text("Reusable"),
          ],
        ),
      ],
    );
  }
}
