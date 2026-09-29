import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});
  final String status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status.trim().toLowerCase()) {
      case 'in-progress':
      case 'in progress':
      case 'inprogress':
        bg = AppColors.statusInProgressBg;
        fg = AppColors.statusInProgressText;
        break;
      case 'pending':
        bg = AppColors.statusPendingBg;
        fg = AppColors.statusPendingText;
        break;
      case 'completed':
      case 'complete':
      case 'fully paid':
      case 'active':
      case 'released':
        bg = AppColors.statusCompletedBg;
        fg = AppColors.statusCompletedText;
        break;
      case 'down payment paid':
      case 'balance due':
        bg = const Color(0xfffef3c7);
        fg = const Color(0xffb45309);
        break;
      default:
        bg = const Color(0xfff1f5f9);
        fg = AppColors.muted;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.2), width: 0.8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
