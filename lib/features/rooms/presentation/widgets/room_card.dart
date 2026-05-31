import 'package:flutter/material.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import 'package:wc2026/l10n/app_localizations.dart';
import '../../domain/entities/room_entity.dart';

class RoomCard extends StatelessWidget {
  final RoomEntity room;
  final String currentUserId;
  final VoidCallback onTap;

  const RoomCard({
    super.key,
    required this.room,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final member = room.getMember(currentUserId);
    final rank = room.getRank(currentUserId);
    final sorted = room.sortedMembers;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.bgCard(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border(isDark)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      room.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface(isDark),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      room.code,
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                        color: AppColors.textSecondary(isDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.border(isDark)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: Row(
                children: [
                  _StatItem(
                    value: '${room.memberCount}',
                    label: l10n.members,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 16),
                  _StatItem(
                    value: '${member?.totalPoints ?? 0}',
                    label: l10n.myPoints,
                    valueColor: AppColors.primary,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 16),
                  _StatItem(
                    value: _rankText(rank),
                    label: l10n.myRank,
                    valueColor: _rankColor(rank),
                    isDark: isDark,
                  ),
                  const Spacer(),
                  _MembersAvatars(
                    members: sorted.take(4).toList(),
                    total: room.memberCount,
                    currentUserId: currentUserId,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '→',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _rankText(int rank) {
    if (rank == 1) return '🥇 $rank';
    if (rank == 2) return '🥈 $rank';
    if (rank == 3) return '🥉 $rank';
    return '$rank';
  }

  Color _rankColor(int rank) {
    if (rank == 1) return AppColors.warning;
    if (rank == 2) return AppColors.finished;
    if (rank == 3) return AppColors.warningDark;
    return AppColors.textSecondaryLight;
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;
  final bool isDark;

  const _StatItem({
    required this.value,
    required this.label,
    required this.isDark,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textPrimary(isDark),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary(isDark),
          ),
        ),
      ],
    );
  }
}

class _MembersAvatars extends StatelessWidget {
  final List<RoomMemberEntity> members;
  final int total;
  final String currentUserId;
  final bool isDark;

  const _MembersAvatars({
    required this.members,
    required this.total,
    required this.currentUserId,
    required this.isDark,
  });

  static const _colors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.accent,
    AppColors.warning,
    AppColors.finished,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...members.asMap().entries.map(
              (e) => Transform.translate(
                offset: Offset(e.key == 0 ? 0 : -6.0, 0),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _colors[e.key % _colors.length],
                    border: Border.all(
                      color: AppColors.bgCard(isDark),
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    e.value.initials.substring(0, 1),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        if (total > 4)
          Container(
            margin: const EdgeInsets.only(left: 4),
            child: Text(
              '+${total - 4}',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary(isDark),
              ),
            ),
          ),
      ],
    );
  }
}