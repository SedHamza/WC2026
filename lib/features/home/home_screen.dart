import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wc2026/features/auth/presentation/providers/auth_provider.dart';
import 'package:wc2026/features/matches/presentation/providers/matches_provider.dart';
import 'package:wc2026/features/matches/presentation/widgets/date_filter.dart';
import 'package:wc2026/features/matches/presentation/widgets/group_filter.dart';
import 'package:wc2026/features/matches/presentation/widgets/match_card.dart';
import 'package:wc2026/features/matches/presentation/widgets/match_list.dart';
import 'package:wc2026/features/matches/presentation/widgets/stage_filter.dart';
import 'package:wc2026/features/profile/presentation/screens/profile_screen.dart';
import 'package:wc2026/features/standings/presentation/screens/standings_screen.dart';
import 'package:wc2026/l10n/app_localizations.dart';
import 'package:wc2026/shared/widgets/app_tab_bar.dart';
import 'package:wc2026/shared/widgets/app_search_bar.dart';
import 'package:wc2026/shared/widgets/empty_state.dart';
import 'package:wc2026/shared/widgets/loading_widget.dart';
import 'package:wc2026/shared/providers/repository_providers.dart' hide matchesProvider, todayMatchesProvider;
import 'package:wc2026/features/matches/domain/entities/match_entity.dart';

final _currentIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(_currentIndexProvider);

    final pages = [
      const _HomePage(),
      const _MatchesPage(),
      const _RoomsPage(),
      const StandingsScreen(),
      const _ProfilePage(),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: _BottomNav(
        currentIndex: currentIndex,
        onTap: (index) =>
            ref.read(_currentIndexProvider.notifier).state = index,
      ),
    );
  }
}

// ── BOTTOM NAV ───────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141824) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? const Color(0xFF1E2433)
                : const Color(0xFFE5E7EB),
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
                label: 'Accueil',
                index: 0,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.sports_soccer_rounded,
                label: 'Matchs',
                index: 1,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.emoji_events_rounded,
                label: 'Rooms',
                index: 2,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.leaderboard_rounded,
                label: 'Classement',
                index: 3,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profil',
                index: 4,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
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
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF002868).withOpacity(0.15)
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
                  ? const Color(0xFF002868)
                  : const Color(0xFF6B7280),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? const Color(0xFF002868)
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── PAGE ACCUEIL ─────────────────────────────────────────────────────────────

class _HomePage extends ConsumerWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todayMatchesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('WC 2026'),
        backgroundColor: const Color(0xFF002868),
        foregroundColor: Colors.white,
      ),
      body: todayAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => EmptyState(
          emoji: '❌',
          message: 'Erreur de connexion',
          action: ElevatedButton(
            onPressed: () => ref.refresh(todayMatchesProvider),
            child: const Text('Réessayer'),
          ),
        ),
        data: (matches) => matches.isEmpty
            ? const EmptyState(
                emoji: '⚽',
                message: 'Aucun match aujourd\'hui',
                subtitle: 'Le tournoi commence le 11 juin 2026',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: matches.length,
                itemBuilder: (context, index) =>
                    MatchCard(match: matches[index]),
              ),
      ),
    );
  }
}

// ── PAGE MATCHS ──────────────────────────────────────────────────────────────

class _MatchesPage extends ConsumerStatefulWidget {
  const _MatchesPage();

  @override
  ConsumerState<_MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends ConsumerState<_MatchesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedGroup = 'Tous';
  String _selectedStage = 'Tous';
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
          if (_selectedGroup != 'Tous') {
            final matchGroup = m.group
                    ?.replaceAll('GROUP_', '')
                    .replaceAll('Group ', '')
                    .trim() ??
                '';
            if (matchGroup != _selectedGroup) return false;
          }
          return m.stage == 'GROUP_STAGE';
        case 1:
          if (_selectedStage != 'Tous') return m.stage == _selectedStage;
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
    final matchesAsync = ref.watch(matchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matchs WC 2026'),
        backgroundColor: const Color(0xFF002868),
        foregroundColor: Colors.white,
        bottom: AppTabBar(
          controller: _tabController,
          onTap: () => setState(() {}),
          tabs: const [
            AppTab(label: 'Groupes'),
            AppTab(label: 'Phases finales'),
            AppTab(label: 'Par date'),
          ],
        ),
      ),
      body: matchesAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => EmptyState(
          emoji: '❌',
          message: 'Erreur de connexion',
          action: ElevatedButton(
            onPressed: () => ref.refresh(matchesProvider),
            child: const Text('Réessayer'),
          ),
        ),
        data: (matches) {
          final filtered = _applyFilters(matches);
          return Column(
            children: [
              AppSearchBar(
                controller: _searchController,
                hint: 'Rechercher une équipe...',
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
                    ? const EmptyState(message: 'Aucun match trouvé')
                    : MatchList(matches: filtered),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── PAGE ROOMS ───────────────────────────────────────────────────────────────

class _RoomsPage extends StatelessWidget {
  const _RoomsPage();

  @override
  Widget build(BuildContext context) => const EmptyState(
        emoji: '🏆',
        message: 'Rooms',
        subtitle: 'En cours de développement',
      );
}

// ── PAGE PROFIL ──────────────────────────────────────────────────────────────

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) => const ProfileScreen();
}