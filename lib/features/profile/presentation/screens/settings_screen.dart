import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  // Compteur pour débloquer le mode test (tap 5x sur la version)
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
        title: const Text('Paramètres'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // ── COMPTE ─────────────────────────────────────────────────────
          _SectionHeader(title: 'Compte', isDark: isDark),
          _SettingsCard(
            isDark: isDark,
            children: [
              _InfoRow(
                icon: Icons.person_outline_rounded,
                label: 'Pseudo',
                value: user?.displayName ?? 'Non défini',
                isDark: isDark,
                onTap: () => _showEditPseudoDialog(context, user),
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
                label: 'Membre depuis',
                value: user?.metadata.creationTime != null
                    ? _formatDate(user!.metadata.creationTime!)
                    : '—',
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── APPARENCE ──────────────────────────────────────────────────
          _SectionHeader(title: 'Apparence', isDark: isDark),
          _SettingsCard(
            isDark: isDark,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.dark_mode_outlined,
                        size: 20, color: AppColors.textSecondary(isDark)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text('Thème',
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
          _SectionHeader(title: 'Langue', isDark: isDark),
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
                  flag: '🇸🇦',
                  label: 'العربية',
                  isSelected: locale.languageCode == 'ar',
                  isDark: isDark,
                  onTap: () =>
                      ref.read(localeProvider.notifier).setLocale('ar')),
            ],
          ),

          const SizedBox(height: 8),

          // ── APPLICATION ────────────────────────────────────────────────

          const SizedBox(height: 8),

          _SectionHeader(title: 'Application', isDark: isDark),
          _SettingsCard(
            isDark: isDark,
            children: [
              // Tap 5x sur la version pour débloquer le mode test
              GestureDetector(
                onTap: () {
                  setState(() => _versionTapCount++);
                  if (_versionTapCount >= 5 && !_testModeUnlocked) {
                    setState(() => _testModeUnlocked = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Text('🧪 Mode test débloqué !'),
                          ],
                        ),
                        backgroundColor: Colors.deepPurple,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: _InfoRow(
                  icon: Icons.info_outline_rounded,
                  label: 'Version',
                  value: _versionTapCount >= 3 && !_testModeUnlocked
                      ? 'Encore ${5 - _versionTapCount}x...'
                      : '1.0.0',
                  isDark: isDark,
                ),
              ),
              _Divider(isDark: isDark),
              _InfoRow(
                icon: Icons.sports_soccer_rounded,
                label: 'Tournoi',
                value: 'FIFA World Cup 2026',
                isDark: isDark,
              ),
            ],
          ),

          // ── MODE TEST (débloqué après 5 taps) ─────────────────────────
          if (_testModeUnlocked) ...[
            const SizedBox(height: 8),
            _SectionHeader(title: '🧪 Développement', isDark: isDark),
            _SettingsCard(
              isDark: isDark,
              children: [
                _InfoRow(
                  icon: Icons.science_outlined,
                  label: 'Simulateur de matchs',
                  value: 'Modifier statut Firestore',
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

  String _formatDate(DateTime date) {
    const months = [
      '',
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  void _showEditPseudoDialog(BuildContext context, User? user) {
    final controller = TextEditingController(text: user?.displayName ?? '');
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Modifier le pseudo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                maxLength: 30,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Ton pseudo...',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
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
                                content: const Text('Pseudo mis à jour !'),
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
                  : const Text('Enregistrer'),
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
              Icon(Icons.check_rounded, size: 20, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
