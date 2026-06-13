import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import 'package:wc2026/shared/providers/score_notifier.dart';
import 'package:wc2026/l10n/app_localizations.dart';
import '../providers/room_provider.dart';
import '../widgets/room_card.dart';
import 'room_detail_screen.dart';
import 'create_room_screen.dart';
import 'join_room_screen.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state.dart';

class RoomsScreen extends ConsumerStatefulWidget {
  const RoomsScreen({super.key});

  @override
  ConsumerState<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends ConsumerState<RoomsScreen> {
  @override
  void initState() {
    super.initState();
    // Calcule les points de tous les membres de mes rooms dès l'ouverture
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculateAllMembers());
  }

  Future<void> _calculateAllMembers() async {
    await ref.read(scoreNotifierProvider.notifier).initializeForRooms();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final roomsAsync = ref.watch(userRoomsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage(isDark),
      appBar: AppBar(
        title: Text(l10n.myRooms),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateRoomScreen()),
            ).then((_) => ref.refresh(userRoomsProvider)),
            child: Text(
              '+ ${l10n.createRoom}',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.infoText(isDark),
        onRefresh: () async {
          await _calculateAllMembers();
          ref.refresh(userRoomsProvider);
        },
        child: roomsAsync.when(
          loading: () => const LoadingWidget(),
          error: (e, _) => EmptyState(
            emoji: '❌',
            message: l10n.loadingError,
            action: ElevatedButton(
              onPressed: () => ref.refresh(userRoomsProvider),
              child: Text(l10n.retry),
            ),
          ),
          data: (rooms) => rooms.isEmpty
              ? _EmptyRooms(
                  onCreate: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateRoomScreen()),
                  ).then((_) => ref.refresh(userRoomsProvider)),
                  onJoin: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const JoinRoomScreen()),
                  ).then((_) => ref.refresh(userRoomsProvider)),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ...rooms.map((room) => RoomCard(
                          room: room,
                          currentUserId: userId,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RoomDetailScreen(roomId: room.id),
                            ),
                          ).then((_) => ref.refresh(userRoomsProvider)),
                        )),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const CreateRoomScreen()),
                            ).then((_) => ref.refresh(userRoomsProvider)),
                            child: Text('+ ${l10n.createRoom}'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const JoinRoomScreen()),
                            ).then((_) => ref.refresh(userRoomsProvider)),
                            child: Text(l10n.joinRoom),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _EmptyRooms extends StatelessWidget {
  final VoidCallback onCreate;
  final VoidCallback onJoin;

  const _EmptyRooms({required this.onCreate, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(l10n.noRooms, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              l10n.noRoomsSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary(isDark)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onCreate,
                child: Text('+ ${l10n.createRoom}'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onJoin,
                child: Text(l10n.joinWithCode),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
