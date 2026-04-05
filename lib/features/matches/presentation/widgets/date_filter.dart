import 'package:flutter/material.dart';

class DateFilter extends StatelessWidget {
  final DateTime? selected;
  final ValueChanged<DateTime?> onSelected;

  const DateFilter({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selected ?? DateTime(2026, 6, 11),
                firstDate: DateTime(2026, 6, 11),
                lastDate: DateTime(2026, 7, 19),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF002868),
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) onSelected(picked);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected != null
                    ? const Color(0xFF002868)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected != null
                      ? const Color(0xFF002868)
                      : const Color(0xFFD1D5DB),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: selected != null
                        ? Colors.white
                        : const Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    selected != null
                        ? '${selected!.day}/${selected!.month}/${selected!.year}'
                        : 'Choisir une date',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: selected != null
                          ? Colors.white
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (selected != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onSelected(null),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                ),
                child: const Text(
                  'Effacer',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}