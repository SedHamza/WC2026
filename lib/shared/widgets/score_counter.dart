import 'package:flutter/material.dart';

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
    return Column(
      children: [
        _ArrowButton(
          icon: Icons.keyboard_arrow_up_rounded,
          onTap: enabled ? () => onChanged(value + 1) : null,
        ),
        const SizedBox(height: 6),
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled
                  ? const Color(0xFF002868)
                  : const Color(0xFFD1D5DB),
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
                  ? const Color(0xFF002868)
                  : const Color(0xFF9CA3AF),
            ),
          ),
        ),
        const SizedBox(height: 6),
        _ArrowButton(
          icon: Icons.keyboard_arrow_down_rounded,
          onTap: enabled && value > 0 ? () => onChanged(value - 1) : null,
        ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ArrowButton({required this.icon, this.onTap});

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
              ? const Color(0xFFEEF2FF)
              : const Color(0xFFF3F4F6),
        ),
        child: Icon(
          icon,
          size: 22,
          color: onTap != null
              ? const Color(0xFF002868)
              : const Color(0xFFD1D5DB),
        ),
      ),
    );
  }
}