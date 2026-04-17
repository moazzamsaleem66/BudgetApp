import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/intro_prefs.dart';
import 'login_screen.dart';
import 'stay_in_control_onboarding_screen.dart';

class PlanBudgetOnboardingScreen extends StatelessWidget {
  const PlanBudgetOnboardingScreen({super.key});

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
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight - 24),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECEDEE),
                              borderRadius: BorderRadius.circular(26),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 138,
                                        padding: const EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF7F7F7),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'MONTHLY GOAL',
                                              style: TextStyle(
                                                color: Color(0xFF6CA089),
                                                letterSpacing: 1.4,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 11,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              '\$4,250.00',
                                              style: TextStyle(color: Color(0xFF333333), fontSize: 20, fontWeight: FontWeight.w800),
                                            ),
                                            const Spacer(),
                                            Stack(
                                              children: [
                                                Container(
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFE3E5E8),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                                Container(
                                                  height: 8,
                                                  width: 102,
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF08A66F),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      width: 82,
                                      height: 138,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF15B987),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.auto_graph_rounded, color: Color(0xFF094B37), size: 24),
                                          SizedBox(height: 14),
                                          Text('DAILY', style: TextStyle(color: Color(0xFF0A4A37), fontWeight: FontWeight.w800, fontSize: 11)),
                                          Text('PULSE', style: TextStyle(color: Color(0xFF0A4A37), fontWeight: FontWeight.w800, fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 68,
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE9EEF5),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: const Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 14,
                                              backgroundColor: Color(0xFFF8FAFC),
                                              child: Icon(Icons.access_time, size: 16, color: Color(0xFF3E8E76)),
                                            ),
                                            SizedBox(width: 10),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Auto-Allocation', style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w700, fontSize: 14)),
                                                SizedBox(height: 2),
                                                Text('Active for November', style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600, fontSize: 12)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      width: 68,
                                      height: 68,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDEE1E4),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                const Color(0xFF9FA4AA),
                                                const Color(0xFF7D838B).withValues(alpha: 0.9),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 34),
                          const Text(
                            'Plan Your Budget',
                            style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800, fontSize: 19),
                          ),
                          const SizedBox(height: 14),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              'Take command of your wealth with bespoke\ndaily limits and monthly forecasts crafted by\nthe Financial Atelier.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500, height: 1.45),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [_dot(), const SizedBox(width: 9), _dot(isActive: true), const SizedBox(width: 9), _dot(), const SizedBox(width: 9), _dot()],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 64,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(builder: (_) => const StayInControlOnboardingScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF08A66F),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: const Text('Next', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFF9FDCC8), width: 1.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextButton(
                              onPressed: () => _finish(context),
                              child: const Text('I\'ll do this later', style: TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.w700, fontSize: 16)),
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

  static Widget _dot({bool isActive = false}) {
    return Container(
      width: isActive ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(color: isActive ? const Color(0xFF08A66F) : const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(99)),
    );
  }
}
