import 'dart:math' as math;

import 'package:flutter/material.dart';

class CircleButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget? child;
  final bool finished;

  const CircleButton({
    Key? key,
    required this.onTap,
    required this.finished,
    this.child,
  }) : super(key: key);

  @override
  State<CircleButton> createState() => _CircleButtonState();
}

class _CircleButtonState extends State<CircleButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> progress;
  late Animation<double> start;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    start = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.900,
          curve: Curves.easeOut,
        ),
      ),
    );

    progress = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.10,
          1.000,
          curve: Curves.easeIn,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapCaller(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onTap();
    }
    _controller.removeStatusListener(_onTapCaller);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        _controller.forward(from: 0.0);
      },
      onTapUp: (details) {
        _controller.addStatusListener(_onTapCaller);
      },
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: SizedBox(
          height: 80,
          width: 80,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: widget.finished
                    ? ButtonFinishedBorderPainter(
                        start: start.value,
                        progress: _controller.isAnimating ? progress.value : 1,
                      )
                    : ButtonBorderPainter(
                        start: start.value,
                        progress: _controller.isAnimating ? progress.value : 1,
                      ),
                child: Center(child: widget.child),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ButtonBorderPainter extends CustomPainter {
  final double start;
  final double progress;

  const ButtonBorderPainter({
    required this.start,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0.0, 0.0, size.width, size.height);
    const gradient = SweepGradient(
      tileMode: TileMode.repeated,
      stops: [0.0, 0.36, 0.70, 1.0],
      colors: [
        Color(0xFFF74C06),
        Color(0xFFF9BC2C),
        Color(0xFFFA2D6E),
        Color(0xFFF74C06),
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width / 2, size.height / 2);
    const radius = 40.0;
    final sweepAngle = 2 * math.pi * progress;
    final startAngle = (math.pi * -0.5) + 2 * math.pi * start;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(ButtonBorderPainter oldDelegate) => oldDelegate.progress != progress;
}

class ButtonFinishedBorderPainter extends CustomPainter {
  final double start;
  final double progress;

  const ButtonFinishedBorderPainter({
    required this.start,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0.0, 0.0, size.width, size.height);
    const gradient = SweepGradient(
      tileMode: TileMode.repeated,
      stops: [0.0, 0.36, 0.70, 1.0],
      colors: [
        Color(0xFFEEEEEE),
        Color(0xFFAAAAAA),
        Color(0xFFCCCCCC),
        Color(0xFFEEEEEE),
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width / 2, size.height / 2);
    const radius = 40.0;
    final sweepAngle = 2 * math.pi * progress;
    final startAngle = (math.pi * -0.5) + 2 * math.pi * start;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(ButtonFinishedBorderPainter oldDelegate) => oldDelegate.progress != progress;
}
