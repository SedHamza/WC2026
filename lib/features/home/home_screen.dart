import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wc2026/features/auth/presentation/providers/auth_provider.dart';
import 'package:wc2026/l10n/app_localizations.dart';

final _currentIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(_currentIndexProvider);
    final l10n = AppLocalizations.of(context)!;

    final pages = [
      const _MatchesPage(),
      const _StandingsPage(),
      const _PronosticsPage(),
      const _NewsPage(),
      const _ProfilePage(),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: _BottomNav(
        currentIndex: currentIndex,
        onTap: (index) =>
            ref.read(_currentIndexProvider.notifier).state = index,
        l10n: l10n,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final AppLocalizations l10n;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141824) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF1E2433) : const Color(0xFFE5E7EB),
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
                  label: l10n.home,
                  index: 0,
                  currentIndex: currentIndex,
                  onTap: onTap),
              _NavItem(
                  icon: Icons.sports_soccer_rounded,
                  label: l10n.matches,
                  index: 1,
                  currentIndex: currentIndex,
                  onTap: onTap),
              _NavItem(
                  icon: Icons.emoji_events_rounded,
                  label: l10n.pronostics,
                  index: 2,
                  currentIndex: currentIndex,
                  onTap: onTap),
              _NavItem(
                  icon: Icons.leaderboard_rounded,
                  label: l10n.standings,
                  index: 3,
                  currentIndex: currentIndex,
                  onTap: onTap),
              _NavItem(
                  icon: Icons.newspaper_rounded,
                  label: l10n.news,
                  index: 4,
                  currentIndex: currentIndex,
                  onTap: onTap),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
              color:
                  isActive ? const Color(0xFF002868) : const Color(0xFF6B7280),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
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

// Pages temporaires — on les développe dans les phases suivantes
class _MatchesPage extends StatelessWidget {
  const _MatchesPage();
  @override
  Widget build(BuildContext context) =>
      _ComingSoon(title: 'Matchs', icon: Icons.sports_soccer_rounded);
}

class _StandingsPage extends StatelessWidget {
  const _StandingsPage();
  @override
  Widget build(BuildContext context) =>
      _ComingSoon(title: 'Classement', icon: Icons.leaderboard_rounded);
}

class _PronosticsPage extends StatelessWidget {
  const _PronosticsPage();
  @override
  Widget build(BuildContext context) =>
      _ComingSoon(title: 'Pronostics', icon: Icons.emoji_events_rounded);
}

class _NewsPage extends StatelessWidget {
  const _NewsPage();
  @override
  Widget build(BuildContext context) =>
      _ComingSoon(title: 'Actualités', icon: Icons.newspaper_rounded);
}

class _ProfilePage extends ConsumerWidget {
  const _ProfilePage();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: const _ComingSoon(title: 'Profil', icon: Icons.person_rounded),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  final String title;
  final IconData icon;
  const _ComingSoon({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF002868).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 40, color: const Color(0xFF002868)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'En cours de développement',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
