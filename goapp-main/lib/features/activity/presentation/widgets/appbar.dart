import "package:flutter/material.dart";

import "../../../../core/utils/responsive.dart";


class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
    this.centerTitle = true,
    this.showBack = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.bottom,
  });

  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool showBack;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(kToolbarHeight + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      toolbarHeight: Responsive.size(context, kToolbarHeight),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: "Saira",
          fontSize: Responsive.font(context, 20),
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      foregroundColor: foregroundColor ?? theme.colorScheme.onSurface,
      elevation: elevation ?? 0,
      bottom: bottom,
      leading: showBack
          ? IconButton(
        icon: const Icon(Icons.chevron_left),
        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
      )
          : null,
      actions: actions,
    );
  }
}
