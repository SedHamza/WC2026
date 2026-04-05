import 'package:flutter/material.dart';
import '../../domain/entities/match_entity.dart';
import 'match_card.dart';

class MatchList extends StatelessWidget {
  final List<MatchEntity> matches;

  const MatchList({super.key, required this.matches});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      itemBuilder: (context, index) => MatchCard(match: matches[index]),
    );
  }
}