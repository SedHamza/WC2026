import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import 'package:wc2026/l10n/app_localizations.dart';
import '../providers/room_provider.dart';

class JoinRoomScreen extends ConsumerStatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  ConsumerState<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends ConsumerState<JoinRoomScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final l10n = AppLocalizations.of(context)!;
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _error = l10n.fieldRequired);
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final room = await ref.read(roomRepositoryProvider).joinRoom(
            code,
            user.uid,
            user.displayName ?? user.email ?? 'Utilisateur',
          );
      if (room == null) {
        setState(() {
          _error = l10n.invalidCode;
          _isLoading = false;
        });
        return;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.joinedRoom(room.name)),
            backgroundColor: AppColors.accent,
          ),
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
      appBar: AppBar(title: Text(l10n.joinRoom)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.roomCode, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 9,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: AppColors.infoText(isDark)),
              decoration: InputDecoration(
                hintText: l10n.roomCodeHint,
                hintStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 2,
                    color: AppColors.textDisabled(isDark)),
                errorText: _error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.askCodeFromAdmin,
              style: TextStyle(
                  fontSize: 12, color: AppColors.textSecondary(isDark)),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _join,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(l10n.joinRoom),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
