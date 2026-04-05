import 'package:flutter/material.dart';

class RadioSelectorItem {
  final int value;
  final String label;

  const RadioSelectorItem({required this.value, required this.label});
}

class RadioSelector extends StatelessWidget {
  final List<RadioSelectorItem> items;
  final int selected;
  final ValueChanged<int> onSelected;
  final Color activeColor;
  final bool enabled;

  const RadioSelector({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
    this.activeColor = const Color(0xFF006847),
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: items.map((item) {
        final isActive = selected == item.value;
        final isNA = item.value == -1 && isActive;
        return GestureDetector(
          onTap: enabled ? () => onSelected(item.value) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isNA
                    ? const Color(0xFFC8102E)
                    : isActive
                        ? activeColor
                        : const Color(0xFFD1D5DB),
                width: isActive ? 2 : 1,
              ),
              color: isNA
                  ? const Color(0xFFFEF2F2)
                  : isActive
                      ? activeColor.withOpacity(0.1)
                      : Colors.transparent,
            ),
            alignment: Alignment.center,
            child: Text(
              item.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isNA
                    ? const Color(0xFFC8102E)
                    : isActive
                        ? activeColor
                        : const Color(0xFF6B7280),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}