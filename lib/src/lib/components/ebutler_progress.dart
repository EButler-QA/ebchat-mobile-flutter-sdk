import 'package:flutter/material.dart';

class EbutlerProgress extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EbutlerProgress();
}

class _EbutlerProgress extends State<EbutlerProgress>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final Tween<double> _tween = Tween(begin: 0.75, end: 2);

  @override
  void initState() {
    _controller = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this);
    _controller.repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: 100,
      child: Stack(
        children: <Widget>[
          Align(
            child: ScaleTransition(
              scale: _tween.animate(CurvedAnimation(
                  parent: _controller, curve: Curves.elasticOut)),
              child: SizedBox(
                height: 100,
                width: 100,
                child:
                    Image.asset(package: "ebchat", "assets/blueMustache.png"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
