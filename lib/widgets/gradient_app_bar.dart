import 'package:flutter/material.dart';

import '../constants/app_text_styles.dart';

import '../router/fluro_navigator.dart';

/// Common gradient AppBar with rounded bottom, matching Home style
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;

  const GradientAppBar({
    super.key,
    required this.titleText,
    this.actions,
    this.showBack = false,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final fg = theme.appBarTheme.foregroundColor ?? Colors.white;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: showBack
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: fg),
              onPressed: onBack ?? () => NavigatorUtils.goBack(context),
            )
          : null,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, primary.withOpacity(0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      title: Text(titleText, style: theme.appBarTheme.titleTextStyle?.copyWith(color: fg) ?? AppTextStyles.h5.copyWith(color: fg)),
      actions: actions,
    );
  }
}

