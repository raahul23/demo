import "package:flutter/material.dart";


import "../../../../core/utils/responsive.dart";

enum AppButtonSize {
  small,
  medium,
  large,
}

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.width,
    this.height,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius,
    this.textStyle,
    this.leading,
    this.trailing,
    this.isLoading = false,
    this.isDisabled = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonSize size;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final TextStyle? textStyle;
  final Widget? leading;
  final Widget? trailing;
  final bool isLoading;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedHeight = height ?? _heightFor(context, size);
    final resolvedPadding = padding ?? _paddingFor(context, size);
    final resolvedRadius = borderRadius ?? _radiusFor(context, size);

    final effectiveOnPressed =
    (isDisabled || isLoading) ? null : onPressed;

    final text = Text(
      label,
      style: (textStyle ?? _textStyleFor(context)).copyWith(
        color: foregroundColor ?? theme.colorScheme.onPrimary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    return SizedBox(
      width: width,
      height: resolvedHeight,
      child: ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? theme.colorScheme.primary,
          foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
          side: borderColor == null ? null : BorderSide(color: borderColor!),
          padding: resolvedPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(resolvedRadius),
          ),
        ),
        child: isLoading
            ? SizedBox(
          width: resolvedHeight * 0.45,
          height: resolvedHeight * 0.45,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              foregroundColor ?? theme.colorScheme.onPrimary,
            ),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 8),
            ],
            Flexible(child: text),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }

  double _heightFor(BuildContext context, AppButtonSize size) {
    switch (size) {
      case AppButtonSize.small:
        return Responsive.size(context, 36);
      case AppButtonSize.medium:
        return Responsive.size(context, 44);
      case AppButtonSize.large:
        return Responsive.size(context, 52);
    }
  }

  EdgeInsetsGeometry _paddingFor(BuildContext context, AppButtonSize size) {
    switch (size) {
      case AppButtonSize.small:
        return EdgeInsets.symmetric(
          horizontal: Responsive.size(context, 12),
        );
      case AppButtonSize.medium:
        return EdgeInsets.symmetric(
          horizontal: Responsive.size(context, 16),
        );
      case AppButtonSize.large:
        return EdgeInsets.symmetric(
          horizontal: Responsive.size(context, 20),
        );
    }
  }

  double _radiusFor(BuildContext context, AppButtonSize size) {
    switch (size) {
      case AppButtonSize.small:
        return Responsive.size(context, 24);
      case AppButtonSize.medium:
        return Responsive.size(context, 24);
      case AppButtonSize.large:
        return Responsive.size(context, 24);
    }
  }

  TextStyle _textStyleFor(BuildContext context) {
    return TextStyle(
      fontSize: Responsive.font(context, 14),
      fontWeight: FontWeight.w600,
    );
  }
}
