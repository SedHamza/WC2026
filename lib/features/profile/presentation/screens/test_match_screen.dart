import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import 'package:wc2026/features/matches/domain/entities/match_entity.dart';
import 'package:wc2026/shared/providers/repository_providers.dart';
import 'package:wc2026/features/rooms/data/repositories/room_repository_impl.dart';
import 'package:wc2026/shared/widgets/loading_widget.dart';

class TestMatchScreen extends ConsumerStatefulWidget {
  const TestMatchScreen({super.key});

  @override
  ConsumerState<TestMatchScreen> createState() => _TestMatchScreenState();
}

class _TestMatchScreenState extends ConsumerState<TestMatchScreen> {
  String _search = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final matchesAsync = ref.watch(matchesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage(isDark),
      appBar: AppBar(
        title: const Text('🧪 Test Matchs'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => _showResetAllDialog(context),
            child: const Text('Reset tout',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner avertissement
          Container(
            width: double.infinity,
            color: Colors.deepPurple.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 16, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mode test — modifications réelles dans Firestore. Reset après les tests.',
                    style: TextStyle(
                        fontSize: 11, color: Colors.deepPurple.shade700),
                  ),
                ),
              ],
            ),
          ),

          // Recherche
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un match...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _search = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
            ),
          ),

          // Liste matchs
          Expanded(
            child: matchesAsync.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => Center(child: Text('Erreur: $e')),
              data: (matches) {
                final filtered = matches.where((m) {
                  if (_search.isEmpty) return true;
                  return m.homeTeamName.toLowerCase().contains(_search) ||
                      m.awayTeamName.toLowerCase().contains(_search);
                }).toList()
                  ..sort((a, b) => a.utcDate.compareTo(b.utcDate));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _MatchTestCard(
                    match: filtered[index],
                    onUpdated: () => ref.refresh(matchesProvider),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showResetAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset tous les matchs ?'),
        content: const Text(
            'Remet tous les matchs IN_PLAY/FINISHED en TIMED avec score null.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _resetAllTestMatches();
              // ignore: unused_result
              ref.refresh(matchesProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Tous les matchs réinitialisés')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset tout'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetAllTestMatches() async {
    final db = FirebaseFirestore.instance;
    final snapshot = await db
        .collection('matches')
        .where('status', whereIn: ['IN_PLAY', 'PAUSED', 'FINISHED']).get();
    final batch = db.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference,
          {'status': 'TIMED', 'homeScore': null, 'awayScore': null});
    }
    await batch.commit();
  }
}

// ── CARD TEST ─────────────────────────────────────────────────────────────────

class _MatchTestCard extends StatefulWidget {
  final MatchEntity match;
  final VoidCallback onUpdated;

  const _MatchTestCard({required this.match, required this.onUpdated});

  @override
  State<_MatchTestCard> createState() => _MatchTestCardState();
}

class _MatchTestCardState extends State<_MatchTestCard> {
  bool _isLoading = false;

  Color _statusColor(String status) {
    switch (status) {
      case 'IN_PLAY':
      case 'PAUSED':
        return Colors.red;
      case 'FINISHED':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'IN_PLAY':
        return '🔴 EN JEU';
      case 'PAUSED':
        return '⏸ PAUSE';
      case 'FINISHED':
        return '✅ TERMINÉ';
      case 'TIMED':
        return '🕐 PRÉVU';
      case 'SCHEDULED':
        return '📅 PLANIFIÉ';
      default:
        return status;
    }
  }

  Future<void> _updateMatch({
    required String status,
    int? homeScore,
    int? awayScore,
  }) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection('matches')
          .doc(widget.match.id)
          .update({
        'status': status,
        'homeScore': homeScore,
        'awayScore': awayScore,
      });

      // Si on met FINISHED → reset isCalculated pour forcer le recalcul
      if (status == 'FINISHED' && homeScore != null) {
        final db = FirebaseFirestore.instance;
        final usersSnap = await db.collection('users').get();
        for (final userDoc in usersSnap.docs) {
          final pronosticRef = db
              .collection('users')
              .doc(userDoc.id)
              .collection('pronostics')
              .doc(widget.match.id);
          final pronosticDoc = await pronosticRef.get();
          if (pronosticDoc.exists) {
            await pronosticRef.update({'isCalculated': false, 'points': 0});
          }
        }
      }

      widget.onUpdated();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Calcul des points directement sans collectionGroup ────────────────────
  Future<void> _calculatePoints() async {
    setState(() => _isLoading = true);
    try {
      final db = FirebaseFirestore.instance;
      final matchId = widget.match.id;

      // Relit le match depuis Firestore pour avoir le score à jour
      final matchDoc = await db.collection('matches').doc(matchId).get();
      if (!matchDoc.exists) {
        setState(() => _isLoading = false);
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Match introuvable'), backgroundColor: Colors.red));
        return;
      }
      final matchData = matchDoc.data()!;
      final home = matchData['homeScore'] as int?;
      final away = matchData['awayScore'] as int?;

      if (home == null || away == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Définis un score d\'abord !'),
          backgroundColor: Colors.orange,
        ));
        setState(() => _isLoading = false);
        return;
      }

      // Récupère tous les users
      final usersSnap = await db.collection('users').get();
      int totalCalculated = 0;

      for (final userDoc in usersSnap.docs) {
        final uid = userDoc.id;

        // Lit le pronostic de cet user pour ce match
        final pronosticDoc = await db
            .collection('users')
            .doc(uid)
            .collection('pronostics')
            .doc(matchId)
            .get();

        if (!pronosticDoc.exists) continue;
        final data = pronosticDoc.data()!;
        if (data['isCalculated'] == true) continue;

        // Calcul des points
        final type = data['type'] == 'exact' ? 'exact' : 'other';
        int points = 0;

        if (type == 'exact') {
          final pHome = data['homeScore'] as int? ?? 0;
          final pAway = data['awayScore'] as int? ?? 0;
          if (pHome == home && pAway == away) points = 25;
        } else {
          final totalGoals = home + away;
          final realWinner = home > away
              ? 1
              : away > home
                  ? 2
                  : 0;
          final winner = data['winner'] as int? ?? -1;
          final maxGoals = data['maxGoals'] as int? ?? -1;
          final minGoals = data['minGoals'] as int? ?? -1;

          if (winner != -1 && winner == realWinner) points += 5;
          if (maxGoals != -1 && totalGoals <= maxGoals) {
            points += ((7 - maxGoals) * 2).clamp(0, 14);
          }
          if (minGoals != -1 && totalGoals >= minGoals) {
            points += (minGoals * 2).clamp(0, 14);
          }
        }

        // Batch update pronostic + user stats
        final batch = db.batch();

        // Met à jour le pronostic
        batch.update(pronosticDoc.reference, {
          'points': points,
          'isCalculated': true,
        });

        // Met à jour les stats user
        final Map<String, dynamic> statsUpdate = {
          'totalPoints': FieldValue.increment(points),
        };

        if (type == 'exact' && points == 25) {
          statsUpdate['exactScoreCount'] = FieldValue.increment(1);
        }
        if (type == 'other') {
          final totalGoals = home + away;
          final realWinner = home > away
              ? 1
              : away > home
                  ? 2
                  : 0;
          final winner = data['winner'] as int? ?? -1;
          final maxGoals = data['maxGoals'] as int? ?? -1;
          final minGoals = data['minGoals'] as int? ?? -1;
          if (winner != -1 && winner == realWinner) {
            statsUpdate['winnerCorrectCount'] = FieldValue.increment(1);
          }
          if (maxGoals != -1 && totalGoals <= maxGoals) {
            statsUpdate['maxGoalsCorrectCount'] = FieldValue.increment(1);
          }
          if (minGoals != -1 && totalGoals >= minGoals) {
            statsUpdate['minGoalsCorrectCount'] = FieldValue.increment(1);
          }
        }

        // Vérifie meilleur match
        final currentBest =
            (userDoc.data()['bestMatchPoints'] as num?)?.toInt() ?? 0;
        if (points > currentBest) {
          statsUpdate['bestMatchId'] = matchId;
          statsUpdate['bestMatchPoints'] = points;
        }

        batch.update(db.collection('users').doc(uid), statsUpdate);
        await batch.commit();
        totalCalculated++;
      }

      widget.onUpdated();

      // Met à jour les rooms pour chaque user calculé
      final db2 = FirebaseFirestore.instance;
      final usersSnap2 = await db2.collection('users').get();
      for (final userDoc in usersSnap2.docs) {
        final uid = userDoc.id;
        final total = (userDoc.data()['totalPoints'] as num?)?.toInt() ?? 0;
        if (total > 0) {
          await RoomRepositoryImpl().updateMemberPoints(uid, total);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              '✅ Points calculés pour $totalCalculated joueur(s) ! Ouvre le profil pour voir.'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showScoreDialog(String targetStatus) {
    final homeCtrl =
        TextEditingController(text: widget.match.homeScore?.toString() ?? '0');
    final awayCtrl =
        TextEditingController(text: widget.match.awayScore?.toString() ?? '0');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(targetStatus == 'IN_PLAY'
            ? '🔴 Simuler EN JEU'
            : targetStatus == 'PAUSED'
                ? '⏸ Simuler PAUSE'
                : '✅ Simuler TERMINÉ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.match.homeTeamName} vs ${widget.match.awayTeamName}',
              style: const TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: homeCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration:
                        InputDecoration(labelText: widget.match.homeTeamName),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('-',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                ),
                Expanded(
                  child: TextField(
                    controller: awayCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration:
                        InputDecoration(labelText: widget.match.awayTeamName),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateMatch(
                status: targetStatus,
                homeScore: int.tryParse(homeCtrl.text) ?? 0,
                awayScore: int.tryParse(awayCtrl.text) ?? 0,
              );
            },
            child: const Text('Appliquer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final match = widget.match;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCard(isDark),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${match.homeTeamName} vs ${match.awayTeamName}',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor(match.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusLabel(match.status),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _statusColor(match.status)),
                  ),
                ),
              ],
            ),
          ),

          // Score actuel
          if (match.homeScore != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '${match.homeScore} - ${match.awayScore}',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _statusColor(match.status)),
              ),
            ),

          Divider(height: 1, color: AppColors.border(isDark)),

          // Boutons
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            Padding(
              padding: const EdgeInsets.all(8),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _ActionBtn(
                      label: '🔴 EN JEU',
                      color: Colors.red,
                      onTap: () => _showScoreDialog('IN_PLAY')),
                  _ActionBtn(
                      label: '⏸ PAUSE',
                      color: Colors.orange,
                      onTap: () => _showScoreDialog('PAUSED')),
                  _ActionBtn(
                      label: '✅ TERMINÉ',
                      color: Colors.green,
                      onTap: () => _showScoreDialog('FINISHED')),
                  // Bouton calculer points — visible seulement si match FINISHED avec score
                  if (match.isFinished && match.homeScore != null)
                    _ActionBtn(
                      label: '🧮 CALCULER PTS',
                      color: Colors.deepPurple,
                      onTap: _calculatePoints,
                    ),
                  _ActionBtn(
                    label: '↺ RESET',
                    color: Colors.grey,
                    onTap: () => _updateMatch(
                        status: 'TIMED', homeScore: null, awayScore: null),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ),
    );
  }
}
