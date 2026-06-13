import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import 'package:wc2026/l10n/app_localizations.dart';
import 'package:wc2026/shared/providers/locale_provider.dart';
import 'package:wc2026/shared/providers/theme_provider.dart';
import 'test_match_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _versionTapCount = 0;
  bool _testModeUnlocked = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.bgPage(isDark),
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // ── COMPTE ─────────────────────────────────────────────────────
          _SectionHeader(title: l10n.account, isDark: isDark),
          _SettingsCard(
            isDark: isDark,
            children: [
              _InfoRow(
                icon: Icons.person_outline_rounded,
                label: l10n.pseudo,
                value: user?.displayName ?? '—',
                isDark: isDark,
                onTap: () => _showEditPseudoDialog(context, user, l10n),
              ),
              _Divider(isDark: isDark),
              _InfoRow(
                icon: Icons.email_outlined,
                label: l10n.email,
                value: user?.email ?? '',
                isDark: isDark,
              ),
              _Divider(isDark: isDark),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: l10n.memberSince,
                value: user?.metadata.creationTime != null
                    ? _formatDate(user!.metadata.creationTime!, locale.languageCode)
                    : '—',
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── APPARENCE ──────────────────────────────────────────────────
          _SectionHeader(title: l10n.appearance, isDark: isDark),
          _SettingsCard(
            isDark: isDark,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.dark_mode_outlined,
                        size: 20, color: AppColors.textSecondary(isDark)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(l10n.darkMode,
                            style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary(isDark)))),
                    _ThemeSelector(
                        themeMode: themeMode, isDark: isDark, ref: ref),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── LANGUE ─────────────────────────────────────────────────────
          _SectionHeader(title: l10n.language, isDark: isDark),
          _SettingsCard(
            isDark: isDark,
            children: [
              _LangOption(
                  flag: '🇫🇷',
                  label: 'Français',
                  isSelected: locale.languageCode == 'fr',
                  isDark: isDark,
                  onTap: () =>
                      ref.read(localeProvider.notifier).setLocale('fr')),
              _Divider(isDark: isDark),
              _LangOption(
                  flag: '🇬🇧',
                  label: 'English',
                  isSelected: locale.languageCode == 'en',
                  isDark: isDark,
                  onTap: () =>
                      ref.read(localeProvider.notifier).setLocale('en')),
              _Divider(isDark: isDark),
              _LangOption(
                  flag: 'MA',
                  label: 'العربية',
                  isSelected: locale.languageCode == 'ar',
                  isDark: isDark,
                  onTap: () =>
                      ref.read(localeProvider.notifier).setLocale('ar')),
            ],
          ),

          const SizedBox(height: 8),

          // ── APPLICATION ────────────────────────────────────────────────
          _SectionHeader(title: l10n.application, isDark: isDark),
          _SettingsCard(
            isDark: isDark,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() => _versionTapCount++);
                  if (_versionTapCount >= 5 && !_testModeUnlocked) {
                    setState(() => _testModeUnlocked = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.testModeUnlocked),
                        backgroundColor: Colors.deepPurple,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: _InfoRow(
                  icon: Icons.info_outline_rounded,
                  label: l10n.appVersion,
                  value: _versionTapCount >= 3 && !_testModeUnlocked
                      ? 'Encore ${5 - _versionTapCount}x...'
                      : '1.0.0',
                  isDark: isDark,
                ),
              ),
              _Divider(isDark: isDark),
              _InfoRow(
                icon: Icons.sports_soccer_rounded,
                label: l10n.tournament,
                value: 'FIFA World Cup 2026',
                isDark: isDark,
              ),
            ],
          ),

          // ── MODE TEST (débloqué après 5 taps) ─────────────────────────
          if (_testModeUnlocked && Platform.isIOS) ...[
            const SizedBox(height: 8),
            _SectionHeader(title: l10n.testMode, isDark: isDark),
            _SettingsCard(
              isDark: isDark,
              children: [
                _InfoRow(
                  icon: Icons.science_outlined,
                  label: l10n.testModeSubtitle,
                  value: '',
                  isDark: isDark,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TestMatchScreen()),
                  ),
                  actionIcon: Icons.arrow_forward_ios_rounded,
                ),
              ],
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Formate la date selon la locale active
  String _formatDate(DateTime date, String languageCode) {
    final locale = languageCode == 'ar'
        ? 'ar'
        : languageCode == 'en'
            ? 'en'
            : 'fr';
    return DateFormat.yMMMMd(locale).format(date);
  }

  void _showEditPseudoDialog(BuildContext context, User? user, AppLocalizations l10n) {
    final controller = TextEditingController(text: user?.displayName ?? '');
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l10n.editPseudo),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                maxLength: 30,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.pseudoHint,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final newName = controller.text.trim();
                      if (newName.isEmpty) return;
                      setState(() => isLoading = true);
                      try {
                        await user?.updateDisplayName(newName);
                        if (user != null) {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .update({'displayName': newName});
                        }
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(l10n.pseudoUpdated),
                                backgroundColor: AppColors.accent),
                          );
                        }
                      } catch (e) {
                        setState(() => isLoading = false);
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}

// ── WIDGETS ───────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(title.toUpperCase(),
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary(isDark),
              letterSpacing: 0.5)),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;
  const _SettingsCard({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: AppColors.bgCard(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border(isDark))),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: AppColors.border(isDark), indent: 48);
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final VoidCallback? onTap;
  final IconData? actionIcon;

  const _InfoRow(
      {required this.icon,
      required this.label,
      required this.value,
      required this.isDark,
      this.onTap,
      this.actionIcon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary(isDark)),
            const SizedBox(width: 12),
            Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 14, color: AppColors.textPrimary(isDark)))),
            Text(value,
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondary(isDark))),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              Icon(actionIcon ?? Icons.edit_outlined,
                  size: 16, color: AppColors.textHint(isDark)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final ThemeMode themeMode;
  final bool isDark;
  final WidgetRef ref;
  const _ThemeSelector(
      {required this.themeMode, required this.isDark, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.bgSurface(isDark),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border(isDark))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ThemeBtn(
              icon: Icons.light_mode_rounded,
              isActive: themeMode == ThemeMode.light,
              isDark: isDark,
              onTap: () =>
                  ref.read(themeProvider.notifier).setTheme(ThemeMode.light)),
          _ThemeBtn(
              icon: Icons.brightness_auto_rounded,
              isActive: themeMode == ThemeMode.system,
              isDark: isDark,
              onTap: () =>
                  ref.read(themeProvider.notifier).setTheme(ThemeMode.system)),
          _ThemeBtn(
              icon: Icons.dark_mode_rounded,
              isActive: themeMode == ThemeMode.dark,
              isDark: isDark,
              onTap: () =>
                  ref.read(themeProvider.notifier).setTheme(ThemeMode.dark)),
        ],
      ),
    );
  }
}

class _ThemeBtn extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;
  const _ThemeBtn(
      {required this.icon,
      required this.isActive,
      required this.isDark,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20)),
        child: Icon(icon,
            size: 18,
            color: isActive ? Colors.white : AppColors.textSecondary(isDark)),
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  final String flag;
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;
  const _LangOption(
      {required this.flag,
      required this.label,
      required this.isSelected,
      required this.isDark,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary(isDark),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400))),
            if (isSelected)
              Icon(Icons.check_rounded, size: 20, color: AppColors.infoText(isDark)),
          ],
        ),
      ),
    );
  }
}