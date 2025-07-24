import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomFormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? placeholder;
  final Icon? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final bool allowOnlyAlphabetic;
  final VoidCallback? onTap;

  const CustomFormField({
    super.key,
    required this.controller,
    required this.label,
    this.placeholder,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.allowOnlyAlphabetic = false,
    this.onTap,
  });

  @override
  State<CustomFormField> createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  bool _isFocused = false;
  bool _hasError = false;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),

        // Form Field Container
        Container(
          decoration: BoxDecoration(
            color:
                widget.enabled
                    ? colorScheme.surface
                    : colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _getBorderColor(colorScheme),
              width: _isFocused ? 2 : 1,
            ),
            boxShadow: [
              if (_isFocused)
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: const Offset(0, 2),
                )
              else
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Focus(
            onFocusChange: (hasFocus) {
              setState(() {
                _isFocused = hasFocus;
              });
            },
            child: TextFormField(
              onTap: widget.onTap,
              inputFormatters: [
                if (widget.allowOnlyAlphabetic)
                  FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z\s]*$')),
              ],
              controller: widget.controller,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              maxLength: widget.maxLength,
              enabled: widget.enabled,
              readOnly: widget.readOnly,
              onChanged: widget.onChanged,
              validator: (value) {
                final error = widget.validator?.call(value);
                setState(() {
                  _hasError = error != null;
                  _errorText = error;
                });
                return error;
              },
              style: theme.textTheme.bodyLarge?.copyWith(
                color:
                    widget.enabled
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withOpacity(0.5),
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: widget.placeholder,
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                prefixIcon:
                    widget.prefixIcon != null
                        ? Padding(
                          padding: const EdgeInsets.only(left: 12, right: 8),
                          child: IconTheme(
                            data: IconThemeData(
                              color:
                                  _isFocused
                                      ? colorScheme.primary
                                      : colorScheme.onSurface.withOpacity(0.6),
                              size: 20,
                            ),
                            child: widget.prefixIcon!,
                          ),
                        )
                        : null,
                suffixIcon:
                    widget.suffixIcon != null
                        ? Padding(
                          padding: const EdgeInsets.only(right: 12, left: 8),
                          child: IconTheme(
                            data: IconThemeData(
                              color: colorScheme.onSurface.withOpacity(0.6),
                              size: 20,
                            ),
                            child: widget.suffixIcon!,
                          ),
                        )
                        : null,
                errorStyle: const TextStyle(height: 0),
              ),
            ),
          ),
        ),

        // Error Text
        if (_hasError && _errorText != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.error_outline, size: 16, color: colorScheme.error),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _errorText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Color _getBorderColor(ColorScheme colorScheme) {
    if (_hasError) {
      return colorScheme.error;
    }
    if (_isFocused) {
      return colorScheme.primary;
    }
    return colorScheme.outline.withOpacity(0.5);
  }
}
