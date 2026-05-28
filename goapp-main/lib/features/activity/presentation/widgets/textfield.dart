import "package:flutter/material.dart";
import "../../../../core/utils/responsive.dart";

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.leading,
    this.trailing,
    this.controller,
    this.onChanged,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.prefixIconColor,
    this.borderColor,
    this.contentPadding,
    this.filled = false,
    this.fillColor,
    this.errorText,
    this.validateOnChange = false,
    this.borderRadius,
  });

  final String label;
  final String? hint;
  final Widget? leading;
  final Widget? trailing;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final int maxLines;
  final int? minLines;
  final Color? prefixIconColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? contentPadding;
  final bool filled;
  final Color? fillColor;
  final String? errorText;
  final bool validateOnChange;
  final double? borderRadius;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  String? _localErrorText;

  @override
  void initState() {
    super.initState();
    _localErrorText = _validate(widget.controller?.text);
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller ||
        widget.validator != oldWidget.validator ||
        widget.errorText != oldWidget.errorText) {
      _localErrorText = _validate(widget.controller?.text);
    }
  }

  String? _validate(String? value) {
    if (widget.errorText != null) return widget.errorText;
    if (widget.validator == null) return null;
    return widget.validator!(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveErrorText = widget.errorText ?? _localErrorText;
    final resolvedRadius =
        widget.borderRadius ?? Responsive.size(context, 24);
    final outlineBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(resolvedRadius),
      borderSide: BorderSide(
        color: widget.borderColor ?? theme.dividerColor,
      ),
    );

    return TextField(
      controller: widget.controller,
      onChanged: (value) {
        widget.onChanged?.call(value);
        if (widget.validateOnChange && widget.validator != null) {
          setState(() {
            _localErrorText = widget.validator!(value);
          });
        }
      },
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: widget.obscureText,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(color: Colors.black),
        hintText: widget.hint,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: widget.leading,
        suffixIcon: widget.trailing,
        prefixIconColor:
        widget.prefixIconColor ?? theme.colorScheme.primary,
        contentPadding: widget.contentPadding ??
            EdgeInsets.symmetric(
              horizontal: Responsive.size(context, 16),
              vertical: Responsive.size(context, 12),
            ),
        filled: widget.filled,
        fillColor: widget.filled
            ? (widget.fillColor ??
                theme.colorScheme.surfaceContainerHighest)
            : null,
        errorText: effectiveErrorText,
        border: outlineBorder,
        enabledBorder: outlineBorder,
        focusedBorder: outlineBorder,
      ),
    );
  }
}
