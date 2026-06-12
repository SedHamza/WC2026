import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wc2026/features/matches/presentation/widgets/date_filter.dart';
import 'package:wc2026/features/matches/presentation/widgets/group_filter.dart';
import 'package:wc2026/features/matches/presentation/widgets/match_card.dart';
import 'package:wc2026/features/matches/presentation/widgets/match_list.dart';
import 'package:wc2026/features/matches/presentation/widgets/stage_filter.dart';
import 'package:wc2026/features/profile/presentation/screens/profile_screen.dart';
import 'package:wc2026/features/rooms/presentation/screens/rooms_screen.dart';
import 'package:wc2026/features/standings/presentation/screens/standings_screen.dart';
import 'package:wc2026/features/pronostics/presentation/screens/match_detail_screen.dart';
import 'package:wc2026/shared/widgets/app_tab_bar.dart';
import 'package:wc2026/shared/widgets/app_search_bar.dart';
import 'package:wc2026/shared/widgets/empty_state.dart';
import 'package:wc2026/shared/widgets/loading_widget.dart';
import 'package:wc2026/shared/providers/repository_providers.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import 'package:wc2026/features/matches/domain/entities/match_entity.dart';
import 'package:wc2026/features/home/presentation/widgets/bottom_nav.dart';
import 'package:wc2026/l10n/app_localizations.dart';
import 'package:wc2026/shared/providers/score_notifier.dart';

final currentIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Démarre le service live au lancement de l'app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(scoreNotifierProvider.notifier).initializeOnLaunch();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentIndexProvider);
    final scoreState = ref.watch(scoreNotifierProvider);

    final pages = [
      const _HomePage(),
      const _MatchesPage(),
      const _RoomsPage(),
      const StandingsScreen(),
      const _ProfilePage(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          pages[currentIndex],
          // Badge live pulsant
          if (scoreState.liveMatchCount > 0 || scoreState.isRefreshingLive)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 12,
              child: _LiveBadge(
                  liveCount: scoreState.liveMatchCount,
                  isRefreshing: scoreState.isRefreshingLive),
            ),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: currentIndex,
        onTap: (index) => ref.read(currentIndexProvider.notifier).state = index,
      ),
    );
  }
}

// Badge live pulsant
class _LiveBadge extends StatefulWidget {
  final int liveCount;
  final bool isRefreshing;
  const _LiveBadge({required this.liveCount, required this.isRefreshing});

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isRefreshing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 1.5)),
            SizedBox(width: 4),
            Text('Sync...',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }
    return FadeTransition(
      opacity: _anim,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.live.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '🔴 LIVE · ${widget.liveCount}',
          style: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _HomePage extends ConsumerWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todayAsync = ref.watch(todayMatchesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage(isDark),
      appBar: AppBar(
        title: Text(l10n.appName),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            onPressed: () {
              ref.refresh(todayMatchesProvider);
              ref.read(scoreNotifierProvider.notifier).forceRefresh();
            },
          ),
        ],
      ),
      body: todayAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => EmptyState(
          emoji: '❌',
          message: l10n.connectionError,
          action: ElevatedButton(
            onPressed: () => ref.refresh(todayMatchesProvider),
            child: Text(l10n.retry),
          ),
        ),
        data: (matches) {
          final liveMatches = matches.where((m) => m.isLive).toList();
          final upcomingMatches = matches.where((m) => m.isUpcoming).toList()
            ..sort((a, b) => a.utcDate.compareTo(b.utcDate));

          if (matches.isEmpty) {
            return EmptyState(
              emoji: '⚽',
              message: l10n.noMatchToday,
              subtitle: l10n.tournamentStarts,
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.refresh(todayMatchesProvider);
              await ref.read(scoreNotifierProvider.notifier).forceRefresh();
            },
            child: CustomScrollView(
              slivers: [
                // ── Section LIVE ──────────────────────────────────────
                if (liveMatches.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _SectionHeader(
                      label: '🔴 LIVE',
                      color: AppColors.live,
                      count: liveMatches.length,
                      isDark: isDark,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _LiveMatchCard(match: liveMatches[i]),
                        childCount: liveMatches.length,
                      ),
                    ),
                  ),
                ],

                // ── Section À VENIR ───────────────────────────────────
                if (upcomingMatches.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _SectionHeader(
                      label: '🕐${l10n.upcomingToday.toUpperCase()}',
                      color: AppColors.infoText(isDark),
                      count: upcomingMatches.length,
                      isDark: isDark,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => MatchCard(match: upcomingMatches[i]),
                        childCount: upcomingMatches.length,
                      ),
                    ),
                  ),
                ],

                // ── Si aucun live ni à venir (que des terminés) ───────
                if (liveMatches.isEmpty && upcomingMatches.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: EmptyState(
                        emoji: '✅',
                        message: 'Tous les matchs du jour sont terminés',
                      ),
                    ),
                  ),

                SliverToBoxAdapter(
                  child: SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── SECTION HEADER ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;
  final int count;
  final bool isDark;

  const _SectionHeader({
    required this.label,
    required this.color,
    required this.count,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

// ── LIVE MATCH CARD ───────────────────────────────────────────────────────────
// Version étendue de MatchCard avec score en temps réel bien visible

class _LiveMatchCard extends StatefulWidget {
  final MatchEntity match;
  const _LiveMatchCard({required this.match});

  @override
  State<_LiveMatchCard> createState() => _LiveMatchCardState();
}

class _LiveMatchCardState extends State<_LiveMatchCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final match = widget.match;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MatchDetailScreen(match: match),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.bgCard(isDark),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: AppColors.live.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.live.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header groupe/stade
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.live.withOpacity(0.08),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(13)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    match.getFormattedStage(context),
                    style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary(isDark),
                        fontWeight: FontWeight.w500),
                  ),
                  FadeTransition(
                    opacity: _anim,
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.live,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.live,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Score
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  // Équipe domicile
                  Expanded(
                    child: Column(
                      children: [
                        _TeamFlag(crest: match.homeTeamCrest, size: 40),
                        const SizedBox(height: 6),
                        Text(
                          match.homeTeamName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(isDark),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Score central
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Text(
                          '${match.homeScore ?? 0} - ${match.awayScore ?? 0}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.live,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Équipe extérieure
                  Expanded(
                    child: Column(
                      children: [
                        _TeamFlag(crest: match.awayTeamCrest, size: 40),
                        const SizedBox(height: 6),
                        Text(
                          match.awayTeamName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(isDark),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
}

// ── FLAG WIDGET ───────────────────────────────────────────────────────────────

class _TeamFlag extends StatelessWidget {
  final String? crest;
  final double size;

  const _TeamFlag({this.crest, this.size = 32});

  @override
  Widget build(BuildContext context) {
    if (crest == null || crest!.isEmpty) {
      return SizedBox(width: size, height: size);
    }
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: crest!.endsWith('.svg')
            ? SvgPicture.network(crest!,
                fit: BoxFit.cover, placeholderBuilder: (_) => const SizedBox())
            : CachedNetworkImage(
                imageUrl: crest!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const SizedBox(),
              ),
      ),
    );
  }
}

class _MatchesPage extends ConsumerStatefulWidget {
  const _MatchesPage();

  @override
  ConsumerState<_MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends ConsumerState<_MatchesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedGroup = 'ALL';
  String _selectedStage = 'ALL';
  String _searchQuery = '';
  DateTime? _selectedDate;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<MatchEntity> _applyFilters(List<MatchEntity> matches) {
    return matches.where((m) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!m.homeTeamName.toLowerCase().contains(q) &&
            !m.awayTeamName.toLowerCase().contains(q)) {
          return false;
        }
      }
      switch (_tabController.index) {
        case 0:
          if (_selectedGroup != 'ALL') {
            final matchGroup = m.group
                    ?.replaceAll('GROUP_', '')
                    .replaceAll('Group ', '')
                    .trim() ??
                '';
            if (matchGroup != _selectedGroup) return false;
          }
          return m.stage == 'GROUP_STAGE';
        case 1:
          if (_selectedStage != 'ALL') return m.stage == _selectedStage;
          return m.stage != 'GROUP_STAGE';
        case 2:
          if (_selectedDate != null) {
            final local = m.utcDate.toLocal();
            return local.day == _selectedDate!.day &&
                local.month == _selectedDate!.month &&
                local.year == _selectedDate!.year;
          }
          return true;
      }
      return true;
    }).toList()
      ..sort((a, b) => a.utcDate.compareTo(b.utcDate));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final matchesAsync = ref.watch(matchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.matches} WC 2026'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: AppTabBar(
          controller: _tabController,
          onTap: () => setState(() {}),
          tabs: [
            AppTab(label: l10n.allGroups),
            AppTab(label: l10n.knockoutStage),
            AppTab(label: l10n.byDate),
          ],
        ),
      ),
      body: matchesAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => EmptyState(
          emoji: '❌',
          message: l10n.connectionError,
          action: ElevatedButton(
            onPressed: () => ref.refresh(matchesProvider),
            child: Text(l10n.retry),
          ),
        ),
        data: (matches) {
          final filtered = _applyFilters(matches);
          return Column(
            children: [
              AppSearchBar(
                controller: _searchController,
                hint: l10n.searchTeam,
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
              if (_tabController.index == 0)
                GroupFilter(
                  selected: _selectedGroup,
                  onSelected: (v) => setState(() => _selectedGroup = v),
                )
              else if (_tabController.index == 1)
                StageFilter(
                  selected: _selectedStage,
                  onSelected: (v) => setState(() => _selectedStage = v),
                )
              else
                DateFilter(
                  selected: _selectedDate,
                  onSelected: (v) => setState(() => _selectedDate = v),
                ),
              Expanded(
                child: filtered.isEmpty
                    ? EmptyState(message: l10n.noMatchFound)
                    : MatchList(matches: filtered),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RoomsPage extends StatelessWidget {
  const _RoomsPage();

  @override
  Widget build(BuildContext context) => const RoomsScreen();
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) => const ProfileScreen();
}
