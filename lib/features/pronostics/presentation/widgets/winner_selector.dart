import 'package:flutter/material.dart';

class WinnerSelector extends StatelessWidget {
  final String homeTeamName;
  final String awayTeamName;
  final int selected;
  final ValueChanged<int> onSelected;
  final bool enabled;

  const WinnerSelector({
    super.key,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.selected,
    required this.onSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _WinnerBtn(
          label: homeTeamName,
          value: 1,
          selected: selected,
          onTap: enabled ? onSelected : null,
        ),
        const SizedBox(width: 6),
        _WinnerBtn(
          label: 'Égalité',
          value: 0,
          selected: selected,
          onTap: enabled ? onSelected : null,
        ),
        const SizedBox(width: 6),
        _WinnerBtn(
          label: awayTeamName,
          value: 2,
          selected: selected,
          onTap: enabled ? onSelected : null,
        ),
      ],
    );
  }
}

class _WinnerBtn extends StatelessWidget {
  final String label;
  final int value;
  final int selected;
  final ValueChanged<int>? onTap;

  const _WinnerBtn({
    required this.label,
    required this.value,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap?.call(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF002868)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? const Color(0xFF002868)
                  : const Color(0xFFD1D5DB),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}