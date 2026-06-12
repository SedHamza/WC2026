import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import 'package:wc2026/features/pronostics/presentation/screens/match_detail_screen.dart';
import 'package:wc2026/features/rooms/presentation/screens/member_profile_screen.dart';
import 'package:wc2026/shared/widgets/empty_state.dart';
import 'package:wc2026/l10n/app_localizations.dart';
import '../providers/room_provider.dart';
import '../../domain/entities/room_entity.dart';
import '../../../matches/domain/entities/match_entity.dart';
import '../../../pronostics/domain/entities/pronostic_entity.dart';
import '../../../pronostics/presentation/providers/pronostic_provider.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/providers/repository_providers.dart';

class RoomDetailScreen extends ConsumerWidget {
  final String roomId;

  const RoomDetailScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final roomAsync = ref.watch(roomDetailProvider(roomId));
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.bgPage(isDark),
      body: roomAsync.when(
        loading: () => const Scaffold(body: LoadingWidget()),
        error: (e, _) => Scaffold(
          appBar: AppBar(),
          body: Center(child: Text(AppLocalizations.of(context)!.loadingError)),
        ),
        data: (room) => _RoomDetailContent(
          room: room,
          currentUserId: userId,
          ref: ref,
        ),
      ),
    );
  }
}

class _RoomDetailContent extends ConsumerWidget {
  final RoomEntity room;
  final String currentUserId;
  final WidgetRef ref;

  const _RoomDetailContent({
    required this.room,
    required this.currentUserId,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rank = room.getRank(currentUserId);
    final matchesAsync = ref.watch(matchesProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 160,
          pinned: true,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: AppColors.primary,
              padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        room.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: room.code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.codeCopied)),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(
                                room.code,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.copy_rounded,
                                  size: 14, color: Colors.white60),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _HeroStat(
                          value: '${room.memberCount}', label: l10n.members),
                      const SizedBox(width: 24),
                      _HeroStat(value: _rankText(rank), label: l10n.myRank),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _SectionTitle(title: l10n.leaderboard),
              _LeaderboardWidget(
                room: room,
                currentUserId: currentUserId,
              ),
              const SizedBox(height: 12),
              _SectionTitle(title: l10n.memberPronostics),
              matchesAsync.maybeWhen(
                data: (matches) => _PronosticsWidget(
                  room: room,
                  matches: matches,
                  currentUserId: currentUserId,
                ),
                orElse: () => const LoadingWidget(),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLeave(context, ref),
                  icon: Icon(Icons.exit_to_app_rounded,
                      color: AppColors.secondary, size: 18),
                  label: Text(
                    l10n.leaveRoom,
                    style: TextStyle(color: AppColors.secondary),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                    side: BorderSide(color: AppColors.secondary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  String _rankText(int rank) {
    if (rank == 1) return '🥇 $rank';
    if (rank == 2) return '🥈 $rank';
    if (rank == 3) return '🥉 $rank';
    return '$rank';
  }

  void _confirmLeave(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.leaveRoomTitle),
        content: Text(l10n.leaveRoomConfirm(room.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(roomRepositoryProvider)
                  .leaveRoom(room.id, currentUserId);
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.leave),
          ),
        ],
      ),
    );
  }
}

// ── CLASSEMENT ────────────────────────────────────────────────────────────────

class _LeaderboardWidget extends StatelessWidget {
  final RoomEntity room;
  final String currentUserId;

  const _LeaderboardWidget({
    required this.room,
    required this.currentUserId,
  });

  static const _rankIcons = ['🥇', '🥈', '🥉'];
  static const _colors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.accent,
    AppColors.warning,
    AppColors.finished,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sorted = room.sortedMembers;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.bgCard(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.bgSubtle(isDark),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                SizedBox(
                    width: 32,
                    child: Text('#',
                        style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary(isDark)),
                        textAlign: TextAlign.center)),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(l10n.team,
                        style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary(isDark)))),
                Text(l10n.points,
                    style: TextStyle(
                        fontSize: 10, color: AppColors.textSecondary(isDark))),
              ],
            ),
          ),
          ...sorted.asMap().entries.map((e) {
            final rank = e.key + 1;
            final member = e.value;
            final isMe = member.userId == currentUserId;

            return GestureDetector(
              // ← Navigation vers le profil du membre
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MemberProfileScreen(
                    userId: member.userId,
                    displayName: member.displayName,
                    totalPoints: member.totalPoints,
                    rank: rank,
                    isOwnProfile: isMe,
                  ),
                ),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.infoBg(isDark) : null,
                  border: Border(
                    top:
                        BorderSide(color: AppColors.border(isDark), width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 32,
                      child: Text(
                        rank <= 3 ? _rankIcons[rank - 1] : '$rank',
                        style: TextStyle(
                          fontSize: rank <= 3 ? 16 : 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary(isDark),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _colors[e.key % _colors.length],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        member.initials.substring(0, 1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.displayName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (isMe)
                            Text(
                              l10n.me,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '${member.totalPoints}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.chevron_right_rounded,
                        size: 16, color: AppColors.textSecondary(isDark)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── PRONOSTICS DES MEMBRES ────────────────────────────────────────────────────

class _PronosticsWidget extends ConsumerWidget {
  final RoomEntity room;
  final List<MatchEntity> matches;
  final String currentUserId;

  const _PronosticsWidget({
    required this.room,
    required this.matches,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<Map<String, Map<String, PronosticEntity>>>(
      future: Future.wait(
        room.members.map((member) async {
          final pronostics = await ref
              .read(pronosticRepositoryProvider)
              .getUserPronostics(member.userId);
          return MapEntry(
            member.userId,
            {for (final p in pronostics) p.matchId: p},
          );
        }),
      ).then((entries) => Map.fromEntries(entries)),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LoadingWidget();

        final pronosticsMap = snapshot.data!;
        final allMatchIds = pronosticsMap.values.expand((m) => m.keys).toSet();

        if (allMatchIds.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: EmptyState(
              emoji: '🎯',
              message: l10n.noPronosticsYet,
              subtitle: l10n.beFirstToPronostic,
            ),
          );
        }

        final pronosticMatches = matches
            .where((m) => allMatchIds.contains(m.id))
            .toList()
          ..sort((a, b) => b.utcDate.compareTo(a.utcDate));

        return Column(
          children: pronosticMatches
              .map((match) => _MatchPronosticsCard(
                    match: match,
                    room: room,
                    currentUserId: currentUserId,
                    pronosticsMap: pronosticsMap,
                  ))
              .toList(),
        );
      },
    );
  }
}

class _MatchPronosticsCard extends ConsumerWidget {
  final MatchEntity match;
  final RoomEntity room;
  final String currentUserId;
  final Map<String, Map<String, PronosticEntity>> pronosticsMap;

  const _MatchPronosticsCard({
    required this.match,
    required this.room,
    required this.currentUserId,
    required this.pronosticsMap,
  });

  static const _colors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.accent,
    AppColors.warning,
    AppColors.finished,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isVisible = match.isFinished || match.isLive;

    final pronostics = room.sortedMembers
        .map((m) => pronosticsMap[m.userId]?[match.id])
        .toList();

    final hasAnyPronostic = pronostics.any((p) => p != null);
    if (!hasAnyPronostic) return const SizedBox();

    return GestureDetector(
      onTap: match.isUpcoming
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MatchDetailScreen(match: match),
                ),
              )
          : null,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        decoration: BoxDecoration(
          color: AppColors.bgCard(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: match.isUpcoming
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.border(isDark),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${match.homeTeamName} vs ${match.awayTeamName}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: match.isLive
                          ? AppColors.errorBg(isDark)
                          : match.isFinished
                              ? AppColors.successBg(isDark)
                              : AppColors.infoBg(isDark),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      match.isLive
                          ? '● LIVE'
                          : match.isFinished
                              ? '${match.homeScore}-${match.awayScore}'
                              : l10n.modify,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: match.isLive
                            ? AppColors.secondary
                            : match.isFinished
                                ? AppColors.successDark
                                : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.border(isDark)),
            ...room.sortedMembers.asMap().entries.map((e) {
              final member = e.value;
              final pronostic = pronostics[e.key];
              final isMe = member.userId == currentUserId;

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      isMe ? AppColors.infoBg(isDark).withOpacity(0.5) : null,
                  border: e.key < room.memberCount - 1
                      ? Border(
                          bottom: BorderSide(
                              color: AppColors.border(isDark), width: 0.5))
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _colors[e.key % _colors.length],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        member.initials.substring(0, 1),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 70,
                      child: Text(
                        isMe
                            ? '${member.firstName} (${l10n.me})'
                            : member.firstName,
                        style: TextStyle(
                          fontSize: 11,
                          color: isMe
                              ? AppColors.primary
                              : AppColors.textSecondary(isDark),
                          fontWeight: isMe ? FontWeight.w500 : FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPronosticText(
                        context: context,
                        pronostic: pronostic,
                        isMe: isMe,
                        isVisible: isVisible,
                        match: match,
                        isDark: isDark,
                        l10n: l10n,
                      ),
                    ),
                    if (isVisible && pronostic != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: pronostic.isCalculated
                              ? pronostic.points > 0
                                  ? AppColors.successBg(isDark)
                                  : AppColors.bgSubtle(isDark)
                              : match.isLive && match.homeScore != null
                                  ? AppColors.errorBg(isDark)
                                  : AppColors.warningBg(isDark),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          () {
                            if (pronostic.isCalculated)
                              return '${pronostic.points}/${pronostic.potentialPoints} pts';
                            if (match.isLive && match.homeScore != null) {
                              final livePts = pronostic.calculatePoints(
                                  match.homeScore!, match.awayScore ?? 0);
                              final maxPts = pronostic.potentialPoints;
                              return '🔴 $livePts/$maxPts pts';
                            }
                            return '—pts';
                          }(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: pronostic.isCalculated
                                ? pronostic.points > 0
                                    ? AppColors.successDark
                                    : AppColors.textSecondary(isDark)
                                : match.isLive && match.homeScore != null
                                    ? AppColors.live
                                    : AppColors.warningDark,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPronosticText({
    required BuildContext context,
    required PronosticEntity? pronostic,
    required bool isMe,
    required bool isVisible,
    required MatchEntity match,
    required bool isDark,
    required AppLocalizations l10n,
  }) {
    if (pronostic == null) {
      return Text(
        isMe ? l10n.noPronostic : l10n.didNotPronostic,
        style: TextStyle(
          fontSize: 10,
          color: AppColors.textHint(isDark),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    if (!isVisible && !isMe) {
      return Row(
        children: [
          Icon(Icons.check_circle_outline_rounded,
              size: 12, color: AppColors.accent),
          const SizedBox(width: 4),
          Text(
            l10n.hasPronostic,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.accent,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return Text(
      _formatPronostic(pronostic, match, l10n),
      style: TextStyle(
        fontSize: 11,
        color: AppColors.textPrimary(isDark),
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  String _formatPronostic(
      PronosticEntity p, MatchEntity match, AppLocalizations l10n) {
    if (p.isExactMode) {
      return '${l10n.exactScoreMode} : ${p.homeScore ?? 0}-${p.awayScore ?? 0}';
    }
    final parts = <String>[];
    if (p.winner != null && p.winner != -1) {
      final winnerName = p.winner == 1
          ? match.homeTeamName
          : p.winner == 2
              ? match.awayTeamName
              : l10n.draw;
      parts.add(winnerName);
    }
    if (p.maxGoals != null && p.maxGoals != -1) {
      parts.add('Max≤${p.maxGoals}');
    }
    if (p.minGoals != null && p.minGoals != -1) {
      parts.add('Min≥${p.minGoals}');
    }
    if (p.bothTeamsScore != null && p.bothTeamsScore != -1) {
      parts.add(p.bothTeamsScore == 1 ? 'BTTS✓' : 'BTTS✗');
    }
    if (parts.isEmpty) return '';
    return parts.join(' · ');
  }
}

// ── HELPERS ───────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary(isDark),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String value;
  final String label;

  const _HeroStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}