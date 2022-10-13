import 'package:flutter/material.dart';

class RipplesAnimation extends StatefulWidget {
  const RipplesAnimation({
    Key? key,
  }) : super(key: key);
  @override
  _RipplesAnimationState createState() => _RipplesAnimationState();
}

class _RipplesAnimationState extends State<RipplesAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _controller1;
  late AnimationController _controller2;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _controller1 = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true, period: const Duration(milliseconds: 2000));
    _controller2 = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true, period: const Duration(milliseconds: 2100));
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        FadeTransition(
            opacity: _controller
              ..drive(CurveTween(
                curve: Curves.easeInOut,
              )),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2,
                  color: Colors.white.withOpacity(0.4),
                  style: BorderStyle.solid,
                ),
              ),
            )),
        FadeTransition(
            opacity: _controller1.drive(CurveTween(
              curve: Curves.easeInOut,
            )),
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2,
                  color: Colors.white.withOpacity(0.4),
                  style: BorderStyle.solid,
                ),
              ),
            )),
        FadeTransition(
            opacity: _controller2.drive(CurveTween(
              curve: Curves.easeInOut,
            )),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2,
                  color: Colors.white.withOpacity(0.4),
                  style: BorderStyle.solid,
                ),
              ),
            )),
      ],
    );
  }
}
