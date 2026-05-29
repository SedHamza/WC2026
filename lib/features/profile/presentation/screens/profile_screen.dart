import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import 'package:wc2026/l10n/app_localizations.dart';
import 'package:wc2026/shared/providers/score_notifier.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../widgets/profile_hero.dart';
import '../widgets/profile_stats_grid.dart';
import '../widgets/pronostic_history_list.dart';
import 'settings_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Calcule mes points + recharge mes stats dès l'ouverture
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(scoreNotifierProvider.notifier).refreshMyProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    // Lit directement depuis scoreNotifierProvider — source unique de vérité
    final scoreState = ref.watch(scoreNotifierProvider);
    final stats = scoreState.myStats;
    final pronostics = scoreState.myPronostics;
    final isLoading = scoreState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.bgPage(isDark),
      appBar: AppBar(
        title: Text(l10n.myProfile),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
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
        color: AppColors.primary,
        onRefresh: () async {
          await ref.read(scoreNotifierProvider.notifier).refreshMyProfile();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Hero — stats en tête
              ProfileHero(user: user, stats: stats),

              const SizedBox(height: 12),

              // Grille de statistiques
              if (isLoading)
                const Padding(
                    padding: EdgeInsets.all(16), child: LoadingWidget())
              else if (stats != null)
                ProfileStatsGrid(stats: stats),

              const SizedBox(height: 12),

              // Header historique
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      l10n.pronosticHistory.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary(isDark),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    if (pronostics.isNotEmpty)
                      Text(
                        '${pronostics.length} ${l10n.pronostics}',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary(isDark)),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Historique des pronostics
              if (isLoading)
                const LoadingWidget()
              else if (pronostics.isEmpty)
                EmptyState(
                  emoji: '🎯',
                  message: l10n.noPronosticsHistory,
                  subtitle: l10n.makeFirstPronostic,
                )
              else
                PronosticHistoryList(pronostics: pronostics),

              const SizedBox(height: 16),

              // Bouton déconnexion
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).signOut();
                    if (context.mounted) context.go('/login');
                  },
                  icon: Icon(Icons.logout_rounded, color: AppColors.secondary),
                  label: Text(l10n.signOut,
                      style: TextStyle(color: AppColors.secondary)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.secondary),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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
