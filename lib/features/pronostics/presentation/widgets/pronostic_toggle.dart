import 'package:flutter/material.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import '../../domain/entities/pronostic_entity.dart';

class PronosticToggle extends StatelessWidget {
  final PronosticType selected;
  final ValueChanged<PronosticType> onChanged;
  final bool enabled;

  const PronosticToggle({
    super.key,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface(isDark),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          _ToggleItem(
            label: 'Résultat exact',
            sublabel: '25 pts',
            isActive: selected == PronosticType.exact,
            onTap: enabled ? () => onChanged(PronosticType.exact) : null,
            activeColor: AppColors.primary,
            isDark: isDark,
          ),
          _ToggleItem(
            label: 'Autres pronostics',
            sublabel: 'jusqu\'à 23 pts',
            isActive: selected == PronosticType.other,
            onTap: enabled ? () => onChanged(PronosticType.other) : null,
            activeColor: AppColors.accent,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool isActive;
  final VoidCallback? onTap;
  final Color activeColor;
  final bool isDark;

  const _ToggleItem({
    required this.label,
    required this.sublabel,
    required this.isActive,
    required this.activeColor,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.bgCard(isDark) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                  )]
                : null,
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? activeColor
                      : AppColors.textSecondary(isDark),
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                sublabel,
                style: TextStyle(
                  fontSize: 10,
                  color: isActive
                      ? activeColor.withOpacity(0.7)
                      : AppColors.textHint(isDark),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}