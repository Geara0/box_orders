import 'package:flutter/material.dart';

class Countdown extends AnimatedWidget {
  final Animation<int> animation;

  const Countdown({
    Key? key,
    required this.animation,
  }) : super(key: key, listenable: animation);

  @override
  build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation.value);

    String timerText = clockTimer.inSeconds.toString();

    return Text(timerText);
  }
}
