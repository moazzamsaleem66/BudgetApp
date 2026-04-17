import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/models/budget_models.dart';
import '../state/budget_state_scope.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = BudgetStateScope.of(context);
    final snapshot = state.analytics;
    final summary = state.summary;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0C9AA7), Color(0xFF67D6CB), Color(0xFFA4E9DA)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -40,
            child: _GlowCircle(size: 270, opacity: 0.14),
          ),
          Positioned(
            left: -110,
            bottom: 40,
            child: _GlowCircle(size: 320, opacity: 0.11),
          ),
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Column(
                children: [
                  _AnalyticsHeader(
                    month: state.selectedMonth,
                    months: state.months,
                    onSelectMonth: state.selectMonth,
                  ),
                  const SizedBox(height: 10),
                  _BudgetVsActualCard(
                    budget: summary.totalBudget,
                    spent: summary.totalSpent,
                    remaining: summary.remainingBudget,
                    progress: summary.progress,
                    currencyCode: state.currencyCode,
                  ),
                  const SizedBox(height: 10),
                  _ChartGlassCard(
                    title: 'Monthly spend line chart',
                    child: SizedBox(
                      height: 120,
                      child: _LineChartMock(values: snapshot.monthlyLine),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ChartGlassCard(
                    title: 'Category pie chart',
                    child: SizedBox(
                      height: 170,
                      child: _PieChartMock(slices: snapshot.pieSlices),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ChartGlassCard(
                    title: 'Weekly spending bar chart',
                    child: SizedBox(
                      height: 120,
                      child: _BarsMock(values: snapshot.weeklyBars),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _SmartInsightsCard(insights: snapshot.insights),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsHeader extends StatelessWidget {
  const _AnalyticsHeader({
    required this.month,
    required this.months,
    required this.onSelectMonth,
  });

  final String month;
  final List<String> months;
  final ValueChanged<String> onSelectMonth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.56), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Date Filter',
            style: TextStyle(
              color: Color(0xFFEAF7FC),
              fontWeight: FontWeight.w800,
              fontSize: 14.5,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final item in months)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(item),
                      selected: item == month,
                      onSelected: (_) => onSelectMonth(item),
                      selectedColor: const Color(0xFF0F8E83),
                      backgroundColor: Colors.white.withValues(alpha: 0.85),
                      labelStyle: TextStyle(
                        color: item == month ? Colors.white : const Color(0xFF2E445D),
                        fontWeight: FontWeight.w700,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      side: BorderSide(
                        color: item == month ? const Color(0xFF0F8E83) : const Color(0xFFD3E6F2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetVsActualCard extends StatelessWidget {
  const _BudgetVsActualCard({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.progress,
    required this.currencyCode,
  });

  final double budget;
  final double spent;
  final double remaining;
  final double progress;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.56), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Budget vs Actual',
            style: TextStyle(color: Color(0xFFEAF7FC), fontWeight: FontWeight.w800, fontSize: 15.5),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MetricMini(
                  title: 'Planned Budget',
                  value: '$currencyCode ${budget.toStringAsFixed(0)}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricMini(
                  title: 'Actual Spent',
                  value: '$currencyCode ${spent.toStringAsFixed(0)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.5),
              color: const Color(0xFF12A973),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Remaining: $currencyCode ${remaining.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Color(0xFFEAF7FC),
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricMini extends StatelessWidget {
  const _MetricMini({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.42)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFDFF3FA),
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmartInsightsCard extends StatelessWidget {
  const _SmartInsightsCard({required this.insights});

  final List<InsightItem> insights;

  @override
  Widget build(BuildContext context) {
    final topInsights = insights.take(3).toList(growable: false);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.52), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Smart Insights',
            style: TextStyle(
              color: Color(0xFFEAF7FC),
              fontWeight: FontWeight.w800,
              fontSize: 15.5,
            ),
          ),
          const SizedBox(height: 8),
          if (topInsights.isEmpty)
            const Text(
              'No insights available.',
              style: TextStyle(color: Color(0xFFE6F5FB), fontWeight: FontWeight.w600),
            )
          else
            for (var i = 0; i < topInsights.length; i++)
              Padding(
                padding: EdgeInsets.only(bottom: i == topInsights.length - 1 ? 0 : 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.36),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.44)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F8E83).withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.auto_awesome_rounded, size: 14, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              topInsights[i].title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              topInsights[i].message,
                              style: const TextStyle(
                                color: Color(0xFFE4F2F8),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _ChartGlassCard extends StatelessWidget {
  const _ChartGlassCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFEAF7FC),
              fontWeight: FontWeight.w700,
              fontSize: 20 / 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white.withValues(alpha: 0.36),
              border: Border.all(color: Colors.white.withValues(alpha: 0.45), width: 1.2),
            ),
            padding: const EdgeInsets.all(8),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _LineChartMock extends StatelessWidget {
  const _LineChartMock({required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _LinePainter(values), size: Size.infinite);
  }
}

class _PieChartMock extends StatelessWidget {
  const _PieChartMock({required this.slices});

  final List<double> slices;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _PiePainter(slices), size: Size.infinite);
  }
}

class _BarsMock extends StatelessWidget {
  const _BarsMock({required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final bars = values.isEmpty ? const [48.0, 26.0, 54.0, 34.0, 31.0, 30.0, 42.0] : values;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: bars
          .map(
            (value) => Container(
              width: 18,
              height: value,
              decoration: BoxDecoration(
                color: const Color(0xFF0A8D7A),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _LinePainter extends CustomPainter {
  const _LinePainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final guide = Paint()
      ..color = Colors.white.withValues(alpha: 0.32)
      ..strokeWidth = 1;

    for (var i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), guide);
    }

    final points = values.isEmpty
        ? const [0.74, 0.56, 0.64, 0.44, 0.57, 0.42, 0.37]
        : values.map((v) => v.clamp(0.0, 1.0).toDouble()).toList(growable: false);

    final paint = Paint()
      ..color = const Color(0xFF235EE9)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final step = points.length == 1 ? 0.0 : size.width / (points.length - 1);
    final path = Path();

    for (var i = 0; i < points.length; i++) {
      final x = i * step;
      final y = size.height * points[i];
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) => oldDelegate.values != values;
}

class _PiePainter extends CustomPainter {
  const _PiePainter(this.slices);

  final List<double> slices;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.38;
    final values = slices.isEmpty ? const [0.2, 0.17, 0.25, 0.38] : slices;
    const colors = [
      Color(0xFF11B83C),
      Color(0xFFF4AA0C),
      Color(0xFF1A49D9),
      Color(0xFF0C8A80),
    ];

    final total = values.fold<double>(0, (a, b) => a + b);
    if (total <= 0) return;

    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * (2 * math.pi);
      final paint = Paint()..color = colors[i % colors.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        true,
        paint,
      );
      start += sweep;
    }

    canvas.drawCircle(center, radius * 0.45, Paint()..color = const Color(0xFFDDF4F2));
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) => oldDelegate.slices != slices;
}
