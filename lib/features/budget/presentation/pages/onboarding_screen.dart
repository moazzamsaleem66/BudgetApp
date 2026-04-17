import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/intro_prefs.dart';
import 'login_screen.dart';
import 'plan_budget_onboarding_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _finish(BuildContext context) async {
    await IntroPrefs.markSeen();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        top: true,
        child: DefaultTextStyle.merge(
          style: GoogleFonts.plusJakartaSans(),
          child: Column(
            children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cardHeight = (constraints.maxHeight * 0.38).clamp(230.0, 270.0);
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight - 24),
                      child: Column(
                        children: [
                          SizedBox(height: constraints.maxHeight < 760 ? 8 : 26),
                          Container(
                            width: 310,
                            height: cardHeight,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F6F5),
                              borderRadius: BorderRadius.circular(34),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0B8D68).withValues(alpha: 0.08),
                                  blurRadius: 36,
                                  offset: const Offset(0, 18),
                                ),
                              ],
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAF9),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 22,
                                    top: 22,
                                    child: Container(
                                      width: 76,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD8EAE3),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  const Positioned(
                                    right: 22,
                                    top: 26,
                                    child: CircleAvatar(radius: 10, backgroundColor: Color(0xFF6CB39D)),
                                  ),
                                  Positioned(
                                    left: 24,
                                    right: 24,
                                    top: cardHeight > 245 ? 108 : 92,
                                    child: SizedBox(
                                      height: 58,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: const [
                                          _Bar(18, Color(0xFFC3EBDD)),
                                          _Bar(30, Color(0xFF78D8BB)),
                                          _Bar(24, Color(0xFFA6E8D4)),
                                          _Bar(46, Color(0xFF0A8961)),
                                          _Bar(34, Color(0xFF67C8AC)),
                                          _Bar(50, Color(0xFF1F8D68)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 18,
                                    right: 18,
                                    bottom: 18,
                                    child: Container(
                                      height: 72,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF0F1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 78,
                                                  height: 9,
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFDBE0E4),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                                const Spacer(),
                                                Container(
                                                  width: 124,
                                                  height: 13,
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF18B07D),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Container(
                                            width: 34,
                                            height: 34,
                                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFD2D5D8)),
                                            child: const Icon(Icons.insights, size: 16, color: Color(0xFF0C8D67)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 34),
                          const Text(
                            'Track Your\nSpending',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF171B22),
                              fontWeight: FontWeight.w800,
                              fontSize: 20.6,
                              height: 1.08,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Master your cash flow with real-\ntime insights and artisanal\nfinancial precision. Monitor every\nexpense as it happens.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _dot(isActive: true),
                              const SizedBox(width: 10),
                              _dot(),
                              const SizedBox(width: 10),
                              _dot(),
                              const SizedBox(width: 10),
                              _dot(),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              SizedBox(
                                width: 126,
                                height: 58,
                                child: OutlinedButton(
                                  onPressed: () => _finish(context),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFF9FDCC8), width: 1.4),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text(
                                    'Skip',
                                    style: TextStyle(color: Color(0xFF087C5D), fontWeight: FontWeight.w700, fontSize: 24 / 1.4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: SizedBox(
                                  height: 58,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => const PlanBudgetOnboardingScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF08A66F),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      elevation: 0,
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Next', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
                                        SizedBox(width: 10),
                                        Icon(Icons.arrow_forward, size: 22),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _dot({bool isActive = false}) {
    return Container(
      width: isActive ? 44 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF08A66F) : const Color(0xFFD1D5DB),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar(this.height, this.color);

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: height,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
    );
  }
}
