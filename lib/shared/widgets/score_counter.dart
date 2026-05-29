import 'package:flutter/material.dart';
import 'package:wc2026/core/constants/app_colors.dart';

class ScoreCounter extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final bool enabled;

  const ScoreCounter({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _ArrowButton(
          icon: Icons.keyboard_arrow_up_rounded,
          onTap: enabled ? () => onChanged(value + 1) : null,
          isDark: isDark,
        ),
        const SizedBox(height: 6),
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled
                  ? AppColors.primary
                  : AppColors.borderStrong(isDark),
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: enabled
                  ? AppColors.primary
                  : AppColors.textHint(isDark),
            ),
          ),
        ),
        const SizedBox(height: 6),
        _ArrowButton(
          icon: Icons.keyboard_arrow_down_rounded,
          onTap: enabled && value > 0 ? () => onChanged(value - 1) : null,
          isDark: isDark,
        ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDark;

  const _ArrowButton({
    required this.icon,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: onTap != null
              ? AppColors.infoBg(isDark)
              : AppColors.bgSurface(isDark),
        ),
        child: Icon(
          icon,
          size: 22,
          color: onTap != null
              ? AppColors.primary
              : AppColors.textDisabled(isDark),
        ),
      ),
    );
  }
}