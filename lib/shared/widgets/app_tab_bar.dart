import 'package:flutter/material.dart';
import 'package:wc2026/core/constants/app_colors.dart';

class AppTab {
  final String label;
  final IconData? icon;

  const AppTab({required this.label, this.icon});
}

class AppTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  final List<AppTab> tabs;
  final VoidCallback? onTap;

  const AppTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.onTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      onTap: (_) => onTap?.call(),
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white60,
      indicatorColor: AppColors.secondary,
      indicatorWeight: 3,
      tabs: tabs
          .map((t) => Tab(
                text: t.label,
                icon: t.icon != null ? Icon(t.icon, size: 16) : null,
                iconMargin: const EdgeInsets.only(bottom: 2),
              ))
          .toList(),
    );
  }
}