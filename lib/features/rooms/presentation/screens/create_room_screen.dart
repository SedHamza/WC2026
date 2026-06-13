import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import 'package:wc2026/l10n/app_localizations.dart';
import '../providers/room_provider.dart';

class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context)!;
    if (_nameController.text.trim().isEmpty) {
      setState(() => _error = l10n.fieldRequired);
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final room = await ref.read(roomRepositoryProvider).createRoom(
            _nameController.text.trim(),
            user.uid,
            user.displayName ?? user.email ?? 'Utilisateur',
          );
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) =>
              _RoomCreatedDialog(roomName: room.name, code: room.code),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _error = l10n.unknownError;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createRoom)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.roomName, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              maxLength: 30,
              decoration: InputDecoration(
                hintText: l10n.roomNameHint,
                errorText: _error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Un code unique sera généré automatiquement\npour partager avec tes amis.',
              style: TextStyle(
                  fontSize: 12, color: AppColors.textSecondary(isDark)),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _create,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(l10n.createRoom),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomCreatedDialog extends StatelessWidget {
  final String roomName;
  final String code;

  const _RoomCreatedDialog({required this.roomName, required this.code});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Text(l10n.roomCreated),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.roomCreatedSuccess(roomName)),
          const SizedBox(height: 16),
          Text(l10n.shareCode,
              style: TextStyle(
                  fontSize: 12, color: AppColors.textSecondary(isDark))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.infoBg(isDark),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              code,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.infoText(isDark),
                  letterSpacing: 2),
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.great),
        ),
      ],
    );
  }
}
