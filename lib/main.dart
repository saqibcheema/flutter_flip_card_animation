import 'package:flutter/material.dart';
import 'dart:math' show pi;

void main() {
  runApp(const MyApp());
}

enum Sides { front, back }

extension on Sides {
  String get text {
    switch (this) {
      case Sides.front:
        return 'front';
      case Sides.back:
        return 'back';
    }
  }

  String get key => text;

  AssetImage get image {
    switch (this) {
      case Sides.front:
        return const AssetImage('front_image_transparent.png');
      case Sides.back:
        return const AssetImage('back_image_transparent.png');
    }
  }
}

class FlipCardAnimation extends StatefulWidget {
  const FlipCardAnimation({super.key});

  @override
  State<FlipCardAnimation> createState() => _FlipCardAnimationState();
}


class _FlipCardAnimationState extends State<FlipCardAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animation = Tween(
      begin: 0.0,
      end: -pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward();

    late MyCard frontWidget;
    late MyCard backWidget;
    late var isDisplayed;
    late var isBackShown;
    frontWidget = MyCard(key: ValueKey(Sides.front),side: Sides.front);
    backWidget  = MyCard(key: ValueKey(Sides.back),side: Sides.back);

    return Scaffold(
      appBar: AppBar(
        title: Text('Flip Card'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: GestureDetector(
        onHorizontalDragUpdate: (details){
          _controller.value += details.delta.dx / context.size!.width;
        },
        onHorizontalDragEnd: (details){
          if(_controller.value > 0.5){
            _controller.forward();
          }else{
            _controller.reverse();
            }
    },
        child: AnimatedBuilder(
          animation: Listenable.merge([_controller]),
          builder: (context, child) {
            isBackShown = _controller.value > 0.5;
            isDisplayed = isBackShown ? backWidget : frontWidget;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..scale(0.7,0.7)
                ..rotateY(_animation.value),
              child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(isBackShown ? -pi : 0.0),
                child: isDisplayed,
              ),
            );
          },
        ),
      ),
    );
  }
}

class MyCard extends StatelessWidget {
  final Sides side;
  // final VoidCallback onTap;
  const MyCard({super.key, required this.side});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        border: BoxBorder.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 6,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(side.image.assetName),
            Text(
              side.name,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const FlipCardAnimation(),
    );
  }
}
