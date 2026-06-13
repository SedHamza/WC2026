import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import 'package:wc2026/l10n/app_localizations.dart';
import 'package:wc2026/features/standings/presentation/widgets/best_third_section.dart';
import '../providers/standings_provider.dart';
import '../widgets/group_standing_section.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/providers/repository_providers.dart';

class StandingsScreen extends ConsumerStatefulWidget {
  const StandingsScreen({super.key});

  @override
  ConsumerState<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends ConsumerState<StandingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _groups = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 13, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final standingsAsync = ref.watch(standingsProvider);
    final matchesAsync = ref.watch(matchesProvider);
    final bestThirds = ref.watch(bestThirdProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.standings),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: AppColors.warningDark,
          indicatorWeight: 3,
          tabAlignment: TabAlignment.start,
          tabs: [
            ..._groups.map((g) => Tab(text: g)),
            Tab(
              child: Text(
                l10n.bestThirds,
                style: const TextStyle(color: Color(0xFF4ADE80)),
              ),
            ),
          ],
        ),
      ),
      body: standingsAsync.when(
        loading: () => Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: List.generate(13, (_) => const LoadingWidget()),
              ),
            ),
          ],
        ),
        error: (e, _) => EmptyState(
          emoji: '❌',
          message: l10n.loadingError,
          action: ElevatedButton(
            onPressed: () => ref.refresh(standingsProvider),
            child: Text(l10n.retry),
          ),
        ),
        data: (standings) => TabBarView(
          controller: _tabController,
          children: [
            ..._groups.map((g) {
              final group = standings.firstWhere(
                (s) => s.groupName == g,
                orElse: () => standings.first,
              );
              return SingleChildScrollView(
                child: GroupStandingSection(
                  group: group,
                  matchesAsync: matchesAsync,
                ),
              );
            }),
            SingleChildScrollView(
              child: BestThirdSection(bestThirds: bestThirds),
            ),
          ],
        ),
      ),
    );
  }
}
