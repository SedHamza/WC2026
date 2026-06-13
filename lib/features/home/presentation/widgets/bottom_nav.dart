import 'package:flutter/material.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import 'package:wc2026/l10n/app_localizations.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard(isDark),
        border: Border(
          top: BorderSide(
            color: AppColors.border(isDark),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                  icon: Icons.home_rounded,
                  label: l10n.home,
                  index: 0,
                  currentIndex: currentIndex,
                  onTap: onTap),
              _NavItem(
                  icon: Icons.sports_soccer_rounded,
                  label: l10n.matches,
                  index: 1,
                  currentIndex: currentIndex,
                  onTap: onTap),
              _NavItem(
                  icon: Icons.emoji_events_rounded,
                  label: l10n.rooms,
                  index: 2,
                  currentIndex: currentIndex,
                  onTap: onTap),
              _NavItem(
                  icon: Icons.leaderboard_rounded,
                  label: l10n.standings,
                  index: 3,
                  currentIndex: currentIndex,
                  onTap: onTap),
              _NavItem(
                  icon: Icons.person_rounded,
                  label: l10n.profile,
                  index: 4,
                  currentIndex: currentIndex,
                  onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActive = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.infoText(isDark).withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive
                  ? AppColors.infoText(isDark)
                  : AppColors.textSecondary(isDark),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? AppColors.infoText(isDark)
                    : AppColors.textSecondary(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
