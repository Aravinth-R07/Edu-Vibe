import 'dart:math';
import 'package:flutter/cupertino.dart';

class BubbleBackground extends StatefulWidget {
  const BubbleBackground({Key? key}) : super(key: key);

  @override
  State<BubbleBackground> createState() => _BubbleBackgroundState();
}

class _BubbleBackgroundState extends State<BubbleBackground> with TickerProviderStateMixin {
  late List<BubbleItem> bubbles;

  @override
  void initState() {
    super.initState();
    // Create 12 random bubbles
    bubbles = List.generate(
      12,
          (index) => BubbleItem(this),
    );
  }

  @override
  void dispose() {
    for (var bubble in bubbles) {
      bubble.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                CupertinoColors.systemGroupedBackground,
                CupertinoColors.systemGroupedBackground.withOpacity(0.9),
              ],
            ),
          ),
        ),
        // Floating bubbles
        ...bubbles.map((bubble) => AnimatedBuilder(
          animation: bubble.animation,
          builder: (context, child) {
            return Positioned(
              left: bubble.position.dx,
              top: bubble.position.dy,
              child: Opacity(
                opacity: bubble.opacity.value,
                child: Transform.scale(
                  scale: bubble.scale.value,
                  child: Container(
                    width: bubble.size,
                    height: bubble.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CupertinoColors.activeBlue.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
            );
          },
        )),
      ],
    );
  }
}

class BubbleItem {
  late AnimationController animation;
  late Animation<double> scale;
  late Animation<double> opacity;
  late Offset position;
  late double size;
  late TickerProvider vsync;
  final Random random = Random();

  BubbleItem(this.vsync) {
    // Create animation controller with random duration
    animation = AnimationController(
      vsync: vsync,
      duration: Duration(seconds: random.nextInt(10) + 15),
    );

    // Random size between 40 and 120
    size = random.nextDouble() * 80 + 40;

    // Random position within screen bounds
    position = Offset(
      random.nextDouble() * 400 - size / 2,
      random.nextDouble() * 700 - size / 2,
    );

    // Create scale animation
    scale = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      ),
    );

    // Create opacity animation
    opacity = Tween<double>(
      begin: 0.1,
      end: 0.3,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      ),
    );

    // Start animation and make it repeat
    animation.repeat(reverse: true);
  }

  void dispose() {
    animation.dispose();
  }
}