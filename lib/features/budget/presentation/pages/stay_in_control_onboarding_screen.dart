import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'login_screen.dart';

class StayInControlOnboardingScreen extends StatelessWidget {
  const StayInControlOnboardingScreen({super.key});

  void _finish(BuildContext context) {
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
                  final cardHeight = (constraints.maxHeight * 0.52).clamp(300.0, 430.0);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight - 28),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: cardHeight,
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEFEF),
                        borderRadius: BorderRadius.circular(36),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Stack(
                          children: [
                            Container(color: const Color(0xFFF5F5F5)),
                            Positioned(
                              left: 6,
                              right: 116,
                              top: 36,
                              child: Transform.rotate(
                                angle: -0.08,
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(12, 11, 12, 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F2F2),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: const [
                                          CircleAvatar(
                                            radius: 12,
                                            backgroundColor: Color(0xFFE3F6EE),
                                            child: Icon(Icons.notifications_active, size: 14, color: Color(0xFF0A9B72)),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'SMART ALERT',
                                                  style: TextStyle(
                                                    color: Color(0xFF208964),
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: 1.0,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                                Text(
                                                  'Budget Milestone',
                                                  style: TextStyle(
                                                    color: Color(0xFF111827),
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDCE2E6),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            width: 160,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF0DA56F),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        '80% of your Dining budget reached',
                                        style: TextStyle(
                                          color: Color(0xFF4B5563),
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 20,
                              right: 20,
                              bottom: 86,
                              child: SizedBox(
                                height: 130,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _bar(60),
                                    _bar(95),
                                    _bar(130, isMain: true),
                                    _bar(82),
                                    _bar(118),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              right: 12,
                              bottom: 48,
                              child: Container(
                                width: 150,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F3F5),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.lightbulb, size: 17, color: Color(0xFF667085)),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'You saved \$124 more\nthan last month.',
                                        style: TextStyle(
                                          color: Color(0xFF111827),
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                          const SizedBox(height: 30),
                          const Text(
                            'Stay in Control',
                            style: TextStyle(
                              color: Color(0xFF171B22),
                              fontWeight: FontWeight.w800,
                              fontSize: 62 / 3,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Receive proactive alerts and curated\ninsights that help you master your\nfinancial flow with artisan precision.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 30 / 2,
                              fontWeight: FontWeight.w500,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 26),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _dot(),
                              const SizedBox(width: 9),
                              _dot(),
                              const SizedBox(width: 9),
                              _dot(isActive: true),
                              const SizedBox(width: 9),
                              _dot(),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 76,
                            child: ElevatedButton(
                              onPressed: () => _finish(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF08A66F),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: const Text(
                                'GET STARTED',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 1.0),
                              ),
                            ),
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

  static Widget _bar(double height, {bool isMain = false}) {
    return Container(
      width: 28,
      height: height,
      decoration: BoxDecoration(
        color: isMain ? const Color(0xFF09A56E) : const Color(0xFFD5D9DE),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  static Widget _dot({bool isActive = false}) {
    return Container(
      width: isActive ? 36 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF08A66F) : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
