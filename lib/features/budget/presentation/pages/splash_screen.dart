import 'dart:async';

import 'package:flutter/material.dart';

import 'landing_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    Timer(const Duration(milliseconds: 3500), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const LandingScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SplashView(fadeAnimation: _fade);
  }
}

class SplashView extends StatelessWidget {
  const SplashView({super.key, this.fadeAnimation});

  final Animation<double>? fadeAnimation;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            color: const Color(0xFF13BD88),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF13BD88).withValues(alpha: 0.24),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.account_balance_wallet_outlined,
            size: 34,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Budget Pro',
          style: TextStyle(
            fontSize: 52 / 3,
            fontWeight: FontWeight.w800,
            color: Color(0xFF091B3D),
            letterSpacing: -0.45,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Budget with confidence, spend with\nprecision.',
          style: TextStyle(
            fontSize: 31 / 3,
            color: Color(0xFF667085),
            height: 1.35,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Container(
          width: 144,
          height: 2.4,
          decoration: BoxDecoration(
            color: const Color(0xFF17B98A),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'ESTABLISHING SECURE CONNECTION',
          style: TextStyle(
            fontSize: 9,
            color: Color(0xFF9AA6B2),
            letterSpacing: 3.6,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF2F5F3),
        ),
        child: CustomPaint(
          painter: _GeometricPatternPainter(),
          child: SafeArea(
            top: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 52),
                child: fadeAnimation == null
                    ? content
                    : FadeTransition(opacity: fadeAnimation!, child: content),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cell = 44.0;
    final cols = (size.width / cell).ceil() + 1;
    final rows = (size.height / cell).ceil() + 1;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final x = col * cell;
        final y = row * cell;
        _drawCube(canvas, Offset(x, y), cell);
      }
    }
  }

  void _drawCube(Canvas canvas, Offset origin, double size) {
    final half = size / 2;
    final center = Offset(origin.dx + half, origin.dy + half);

    final top = Path()
      ..moveTo(center.dx, origin.dy)
      ..lineTo(origin.dx + size, center.dy)
      ..lineTo(center.dx, origin.dy + size)
      ..lineTo(origin.dx, center.dy)
      ..close();

    final left = Path()
      ..moveTo(origin.dx, center.dy)
      ..lineTo(center.dx, origin.dy + size)
      ..lineTo(origin.dx, origin.dy + size + half)
      ..lineTo(origin.dx - half, origin.dy + size)
      ..close();

    final right = Path()
      ..moveTo(origin.dx + size, center.dy)
      ..lineTo(center.dx, origin.dy + size)
      ..lineTo(origin.dx + size + half, origin.dy + size)
      ..lineTo(origin.dx + size, origin.dy + size + half)
      ..close();

    final topPaint = Paint()..color = const Color(0xFFDBE8E5).withValues(alpha: 0.16);
    final leftPaint = Paint()..color = const Color(0xFFE8F0EE).withValues(alpha: 0.21);
    final rightPaint = Paint()..color = const Color(0xFFD3E2DE).withValues(alpha: 0.14);

    canvas.save();
    canvas.translate(-half, -half);
    canvas.drawPath(top, topPaint);
    canvas.drawPath(left, leftPaint);
    canvas.drawPath(right, rightPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

