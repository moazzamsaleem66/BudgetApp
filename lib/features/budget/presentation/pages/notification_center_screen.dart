import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const notices = [
      _NoticeData(
        icon: Icons.warning_amber_rounded,
        title: 'Budget warning',
        message: 'Food budget is almost finished.',
        time: '12m ago',
        tone: _NoticeTone.warning,
        unread: true,
      ),
      _NoticeData(
        icon: Icons.receipt_long_rounded,
        title: 'Bill reminder',
        message: 'Internet bill due tomorrow.',
        time: '1h ago',
        tone: _NoticeTone.info,
        unread: true,
      ),
      _NoticeData(
        icon: Icons.emoji_events_rounded,
        title: 'Goal completed',
        message: 'Emergency fund reached 100 KD.',
        time: 'Yesterday',
        tone: _NoticeTone.success,
      ),
      _NoticeData(
        icon: Icons.summarize_rounded,
        title: 'Monthly summary ready',
        message: 'March summary is now available.',
        time: '2 days ago',
        tone: _NoticeTone.neutral,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F9),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 54, 16, 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0FA583), Color(0xFF0A8E95)],
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0A8E95).withValues(alpha: 0.24),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      tooltip: 'Back',
                    ),
                    const Expanded(
                      child: Text(
                        'Notification Center',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 28 / 1.4,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(foregroundColor: Colors.white),
                      child: const Text(
                        'Mark all read',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _HeaderPill(label: '${notices.where((n) => n.unread).length} Unread'),
                    const SizedBox(width: 8),
                    const _HeaderPill(label: 'Today'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              itemCount: notices.length,
              itemBuilder: (context, index) => _NoticeTile(notice: notices[index]),
            ),
          ),
        ],
      ),
    );
  }
}

enum _NoticeTone { warning, info, success, neutral }

class _NoticeData {
  const _NoticeData({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.tone,
    this.unread = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final String time;
  final _NoticeTone tone;
  final bool unread;
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.26)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class _NoticeTile extends StatelessWidget {
  const _NoticeTile({
    required this.notice,
  });

  final _NoticeData notice;

  @override
  Widget build(BuildContext context) {
    final palette = _tonePalette(notice.tone);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: palette.bg,
                shape: BoxShape.circle,
              ),
              child: Icon(notice.icon, color: palette.fg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notice.title,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20 / 1.3),
                        ),
                      ),
                      if (notice.unread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notice.message,
                    style: const TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              notice.time,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

({Color bg, Color fg}) _tonePalette(_NoticeTone tone) {
  switch (tone) {
    case _NoticeTone.warning:
      return (bg: const Color(0xFFFFF5E6), fg: const Color(0xFFF59E0B));
    case _NoticeTone.info:
      return (bg: const Color(0xFFE8F3FF), fg: const Color(0xFF3B82F6));
    case _NoticeTone.success:
      return (bg: const Color(0xFFE9FCEF), fg: const Color(0xFF10B981));
    case _NoticeTone.neutral:
      return (bg: const Color(0xFFEAF2F4), fg: const Color(0xFF0F766E));
  }
}
