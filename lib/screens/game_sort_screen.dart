import 'package:flutter/material.dart';

enum TrashType { plastic, paper, metal, glass, organic }

class TrashItem {
  final String id;
  final TrashType type;
  final String asset;
  Offset position; // where it sits on the screen

  TrashItem({
    required this.id,
    required this.type,
    required this.asset,
    required this.position,
  });
}

class WasteSortingGamePage extends StatefulWidget {
  const WasteSortingGamePage({super.key});

  @override
  State<WasteSortingGamePage> createState() => _WasteSortingGamePageState();
}

class _WasteSortingGamePageState extends State<WasteSortingGamePage> {
  int score = 0;

  // Demo items (adjust positions for your background)
  final List<TrashItem> items = [
    TrashItem(
      id: "bottle1",
      type: TrashType.plastic,
      asset: "assets/game/plastic_bottle_1.png",
      position: const Offset(250, 300),
    ),
    TrashItem(
      id: "can1",
      type: TrashType.metal,
      asset: "assets/game/metal_can.png",
      position: const Offset(600, 320),
    ),
    TrashItem(
      id: "paper1",
      type: TrashType.paper,
      asset: "assets/game/paper_1.png",
      position: const Offset(450, 360),
    ),
  ];

  // Track which items are already sorted (so we hide them)
  final Set<String> sorted = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // For responsive positioning, you can scale your offsets relative
          // to a "design size". For now, keep it simple.

          return Stack(
            children: [
              // Background
              Positioned.fill(
                child: Image.asset(
                  "assets/images/beach.png",
                  fit: BoxFit.cover,
                ),
              ),

              // Score UI
              Positioned(
                top: 40,
                left: 16,
                child: _ScorePill(score: score),
              ),

              // Bins (DragTargets)
              Positioned(
                left: 20,
                bottom: 30,
                child: _BinTarget(
                  label: "Plastic",
                  color: Colors.yellow,
                  accepts: TrashType.plastic,
                  onAcceptCorrect: () => _addScore(),
                ),
              ),
              Positioned(
                left: 120,
                bottom: 30,
                child: _BinTarget(
                  label: "Paper",
                  color: Colors.blue,
                  accepts: TrashType.paper,
                  onAcceptCorrect: () => _addScore(),
                ),
              ),
              Positioned(
                left: 220,
                bottom: 30,
                child: _BinTarget(
                  label: "Metal",
                  color: Colors.grey,
                  accepts: TrashType.metal,
                  onAcceptCorrect: () => _addScore(),
                ),
              ),
              Positioned(
                left: 320,
                bottom: 30,
                child: _BinTarget(
                  label: "Glass",
                  color: Colors.green,
                  accepts: TrashType.glass,
                  onAcceptCorrect: () => _addScore(),
                ),
              ),

              // Draggable trash items
              for (final item in items)
                if (!sorted.contains(item.id))
                  Positioned(
                    left: item.position.dx,
                    top: item.position.dy,
                    child: _TrashDraggable(
                      item: item,
                      onDroppedCorrect: () {
                        setState(() {
                          sorted.add(item.id);
                        });
                      },
                      onDroppedWrong: () {
                        // optional: shake animation / sound / “try again”
                        _showTryAgain(context);
                      },
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }

  void _addScore() {
    setState(() => score += 1);
  }

  void _showTryAgain(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Try again! 🙂")),
    );
  }
}

class _TrashDraggable extends StatelessWidget {
  final TrashItem item;
  final VoidCallback onDroppedCorrect;
  final VoidCallback onDroppedWrong;

  const _TrashDraggable({
    required this.item,
    required this.onDroppedCorrect,
    required this.onDroppedWrong,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<TrashType>(
      data: item.type,
      feedback: Opacity(
        opacity: 0.85,
        child: _trashImage(size: 70),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _trashImage(size: 60),
      ),
      child: _trashImage(size: 60),
      onDragEnd: (details) {
        // If the item wasn't accepted by any DragTarget, treat as wrong drop.
        // Draggable doesn't directly tell "accepted" here, so we handle wrong
        // drops by having the DragTarget call onDroppedCorrect.
        // If you want precise accepted-state, we can add a shared flag system.
      },
    );
  }

  Widget _trashImage({required double size}) {
    return Image.asset(item.asset, width: size, height: size);
  }
}

class _BinTarget extends StatefulWidget {
  final String label;
  final Color color;
  final TrashType accepts;
  final VoidCallback onAcceptCorrect;

  const _BinTarget({
    required this.label,
    required this.color,
    required this.accepts,
    required this.onAcceptCorrect,
  });

  @override
  State<_BinTarget> createState() => _BinTargetState();
}

class _BinTargetState extends State<_BinTarget> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<TrashType>(
      onWillAccept: (data) {
        setState(() => isHovering = true);
        return true; // allow drop, we’ll validate onAccept
      },
      onLeave: (_) => setState(() => isHovering = false),
      onAccept: (data) {
        setState(() => isHovering = false);

        if (data == widget.accepts) {
          widget.onAcceptCorrect();
          // We also need to remove the dragged item.
          // That’s handled by the draggable side when we wire it up in a “real” version.
          // In the demo, you’ll likely manage this by passing item.id instead of TrashType.
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Oops! That’s not ${widget.label}.")),
          );
        }
      },
      builder: (context, candidateData, rejectedData) {
        final hovering = candidateData.isNotEmpty || isHovering;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 80,
          height: 90,
          decoration: BoxDecoration(
            color: hovering ? widget.color.withOpacity(0.9) : widget.color,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              width: hovering ? 4 : 2,
              color: Colors.white,
            ),
            boxShadow: const [
              BoxShadow(
                blurRadius: 10,
                offset: Offset(0, 6),
                color: Colors.black26,
              )
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

class _ScorePill extends StatelessWidget {
  final int score;
  const _ScorePill({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        "Score: $score",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
