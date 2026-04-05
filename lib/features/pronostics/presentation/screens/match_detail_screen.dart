import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../matches/domain/entities/match_entity.dart';
import '../widgets/match_hero_banner.dart';
import '../widgets/pronostic_card.dart';
import '../providers/pronostic_provider.dart';

class MatchDetailScreen extends ConsumerStatefulWidget {
  final MatchEntity match;

  const MatchDetailScreen({super.key, required this.match});

  @override
  ConsumerState<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends ConsumerState<MatchDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Charge le pronostic existant
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final existing = await ref
          .read(pronosticRepositoryProvider)
          .getPronostic(
            widget.match.id,
            ref.read(currentUserIdProvider),
          );
      ref
          .read(pronosticNotifierProvider(widget.match.id).notifier)
          .init(existing);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF002868),
        foregroundColor: Colors.white,
        title: Text(
          '${widget.match.homeTeamName} vs ${widget.match.awayTeamName}',
          style: const TextStyle(fontSize: 14),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero banner
            MatchHeroBanner(match: widget.match),

            // Pronostic
            PronosticCard(
              matchId: widget.match.id,
              homeTeamName: widget.match.homeTeamName,
              awayTeamName: widget.match.awayTeamName,
              matchStarted: widget.match.isLive || widget.match.isFinished,
            ),

            // Informations du match
            _MatchInfoCard(match: widget.match),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _MatchInfoCard extends StatelessWidget {
  final MatchEntity match;

  const _MatchInfoCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final local = match.utcDate.toLocal();
    const months = [
      '', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              'INFORMATIONS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          _InfoRow(label: 'Compétition', value: 'FIFA World Cup 2026'),
          _InfoRow(label: 'Phase', value: match.formattedStage),
          if (match.group != null)
            _InfoRow(
              label: 'Groupe',
              value: 'Groupe ${match.group!.replaceAll('GROUP_', '')}',
            ),
          if (match.matchday != null)
            _InfoRow(
              label: 'Journée',
              value: 'Journée ${match.matchday}',
            ),
          _InfoRow(
            label: 'Date',
            value: '${local.day} ${months[local.month]} ${local.year}',
          ),
          _InfoRow(
            label: 'Heure',
            value:
                '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final label;
  final value;
  final bool isLast;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}