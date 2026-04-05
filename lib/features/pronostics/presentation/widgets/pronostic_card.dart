import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pronostic_provider.dart';
import '../../domain/entities/pronostic_entity.dart';
import 'pronostic_toggle.dart';
import 'exact_score_widget.dart';
import 'other_pronostics_widget.dart';
import '../providers/pronostic_provider.dart';

class PronosticCard extends ConsumerWidget {
  final String matchId;
  final String homeTeamName;
  final String awayTeamName;
  final bool matchStarted;

  const PronosticCard({
    super.key,
    required this.matchId,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.matchStarted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PronosticFormState state =
        ref.watch(pronosticNotifierProvider(matchId));
    final notifier = ref.read(pronosticNotifierProvider(matchId).notifier);
    final enabled = !matchStarted;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF002868), width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mon Pronostic',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF002868),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF002868),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${state.potentialPoints} pts',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          if (matchStarted)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_rounded, size: 14, color: Color(0xFFC8102E)),
                  SizedBox(width: 6),
                  Text(
                    'Match commencé — pronostic verrouillé',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFC8102E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 14),

          // Toggle
          PronosticToggle(
            selected: state.type,
            onChanged: notifier.setType,
            enabled: enabled,
          ),

          const SizedBox(height: 16),

          // Contenu selon le mode
          if (state.type == PronosticType.exact)
            ExactScoreWidget(
              homeTeamName: homeTeamName,
              awayTeamName: awayTeamName,
              homeScore: state.homeScore,
              awayScore: state.awayScore,
              onHomeChanged: notifier.setHomeScore,
              onAwayChanged: notifier.setAwayScore,
              enabled: enabled,
            )
          else
            OtherPronosticsWidget(
              homeTeamName: homeTeamName,
              awayTeamName: awayTeamName,
              winner: state.winner,
              maxGoals: state.maxGoals,
              minGoals: state.minGoals,
              onWinnerChanged: notifier.setWinner,
              onMaxGoalsChanged: notifier.setMaxGoals,
              onMinGoalsChanged: notifier.setMinGoals,
              potentialPoints: state.potentialPoints,
              enabled: enabled,
            ),

          const SizedBox(height: 14),

          // Boutons
          if (enabled) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.isSaving ? null : notifier.save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: state.type == PronosticType.exact
                      ? const Color(0xFF002868)
                      : const Color(0xFF006847),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: state.isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        state.isSaved
                            ? 'Mettre à jour'
                            : 'Confirmer le pronostic',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            if (state.isSaved) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: notifier.reset,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Effacer',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ],

          if (state.isSaved && !matchStarted)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 14, color: Color(0xFF006847)),
                  const SizedBox(width: 4),
                  Text(
                    'Pronostic enregistré',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF006847),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
