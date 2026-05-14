import 'package:flutter/material.dart';

class TimerDisplay extends StatelessWidget {
  const TimerDisplay({super.key, required this.remaining, required this.total});

  final Duration remaining;
  final Duration total;

  @override
  Widget build(BuildContext context) {
    final totalSeconds = total.inSeconds;
    final remainingSeconds = remaining.inSeconds;
    final value = totalSeconds <= 0
        ? 0.0
        : (remainingSeconds / totalSeconds).clamp(0.0, 1.0);

    final minutes = remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = remaining.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CircularProgressIndicator(value: value, strokeWidth: 12),
          ),
          Text(
            '$minutes:$seconds',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }
}
