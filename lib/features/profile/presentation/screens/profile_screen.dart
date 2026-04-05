import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/pronostics/data/repositories/pronostic_repository_impl.dart';
import '../../../../features/pronostics/domain/entities/pronostic_entity.dart';
import '../../../../features/pronostics/domain/entities/user_stats_entity.dart';
import '../../../../features/pronostics/presentation/providers/pronostic_provider.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../widgets/profile_hero.dart';
import '../widgets/profile_stats_grid.dart';
import '../widgets/pronostic_history_list.dart';

final _userStatsProvider = FutureProvider<UserStatsEntity?>((ref) async {
  final userId = ref.read(currentUserIdProvider);
  if (userId.isEmpty) return null;
  return PronosticRepositoryImpl().getUserStats(userId);
});

final _userPronosticsProvider =
    FutureProvider<List<PronosticEntity>>((ref) async {
  final userId = ref.read(currentUserIdProvider);
  if (userId.isEmpty) return [];
  return PronosticRepositoryImpl().getUserPronostics(userId);
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final statsAsync = ref.watch(_userStatsProvider);
    final pronosticsAsync = ref.watch(_userPronosticsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: const Color(0xFF002868),
        foregroundColor: Colors.white,
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
      body: RefreshIndicator(
        color: const Color(0xFF002868),
        onRefresh: () async {
          ref.refresh(_userStatsProvider);
          ref.refresh(_userPronosticsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Hero
              statsAsync.when(
                loading: () => ProfileHero(
                  user: user,
                  stats: null,
                ),
                error: (_, __) => ProfileHero(user: user, stats: null),
                data: (stats) => ProfileHero(user: user, stats: stats),
              ),

              const SizedBox(height: 12),

              // Stats grid
              statsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: LoadingWidget(),
                ),
                error: (_, __) => const SizedBox(),
                data: (stats) => stats != null
                    ? ProfileStatsGrid(stats: stats)
                    : const SizedBox(),
              ),

              const SizedBox(height: 12),

              // Historique
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      'HISTORIQUE DES PRONOSTICS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    pronosticsAsync.maybeWhen(
                      data: (list) => Text(
                        '${list.length} pronostics',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      orElse: () => const SizedBox(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              pronosticsAsync.when(
                loading: () => const LoadingWidget(),
                error: (_, __) => const EmptyState(
                  emoji: '❌',
                  message: 'Erreur de chargement',
                ),
                data: (pronostics) => pronostics.isEmpty
                    ? const EmptyState(
                        emoji: '🎯',
                        message: 'Aucun pronostic encore',
                        subtitle:
                            'Fais tes premiers pronostics sur les matchs !',
                      )
                    : PronosticHistoryList(pronostics: pronostics),
              ),

              const SizedBox(height: 16),

              // Bouton déconnexion
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).signOut();
                    if (context.mounted) context.go('/login');
                  },
                  icon: const Icon(Icons.logout_rounded,
                      color: Color(0xFFC8102E)),
                  label: const Text(
                    'Se déconnecter',
                    style: TextStyle(color: Color(0xFFC8102E)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFC8102E)),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}