import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CustomDropdown<T> extends StatefulWidget {
  final String label;
  final String? placeholder;
  final List<T> items;
  final T? selectedValue;
  final void Function(T?) onChanged;
  final String Function(T) itemToString;
  final Widget Function(T)? itemBuilder; // Optional custom item builder
  final String? Function(T?)? validator;
  final bool enabled;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    required this.itemToString,
    this.placeholder,
    this.itemBuilder,
    this.validator,
    this.enabled = true,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
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
        /// Label
        Text(
          widget.label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 8),

        /// Dropdown field
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
              _validateValue();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DropdownButton2<T>(
                value: widget.selectedValue,
                hint: Text(
                  widget.placeholder ?? 'Select',
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                isExpanded: true,
                underline: const SizedBox(),
                items:
                    widget.items
                        .map(
                          (item) => DropdownMenuItem<T>(
                            value: item,
                            child:
                                widget.itemBuilder != null
                                    ? widget.itemBuilder!(item)
                                    : Text(
                                      widget.itemToString(item),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            widget.enabled
                                                ? colorScheme.onSurface
                                                : colorScheme.onSurface
                                                    .withOpacity(0.5),
                                      ),
                                    ),
                          ),
                        )
                        .toList(),
                onChanged:
                    widget.enabled
                        ? (value) {
                          widget.onChanged(value);
                          _validateValue();
                        }
                        : null,
                buttonStyleData: ButtonStyleData(
                  height: 44, // Adjusted to match form field height
                  width: double.infinity,
                  padding: EdgeInsets.zero,
                  decoration: const BoxDecoration(color: Colors.transparent),
                ),
                iconStyleData: IconStyleData(
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color:
                        _isFocused
                            ? colorScheme.primary
                            : colorScheme.onSurface.withOpacity(0.6),
                  ),
                  iconSize: 24,
                ),
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: colorScheme.surface,
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.15),
                        blurRadius: 16,
                        spreadRadius: 4,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  scrollbarTheme: ScrollbarThemeData(
                    radius: const Radius.circular(40),
                    thickness: WidgetStateProperty.all(6),
                    thumbVisibility: WidgetStateProperty.all(true),
                    thumbColor: WidgetStateProperty.all(
                      colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                ),
                menuItemStyleData: MenuItemStyleData(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  overlayColor: WidgetStateProperty.resolveWith<Color?>((
                    Set<WidgetState> states,
                  ) {
                    if (states.contains(WidgetState.hovered)) {
                      return colorScheme.primary.withOpacity(0.08);
                    }
                    if (states.contains(WidgetState.pressed)) {
                      return colorScheme.primary.withOpacity(0.12);
                    }
                    return null;
                  }),
                ),
              ),
            ),
          ),
        ),

        /// Error Text
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

  void _validateValue() {
    if (widget.validator != null) {
      final error = widget.validator!(widget.selectedValue);
      setState(() {
        _hasError = error != null;
        _errorText = error;
      });
    }
  }
}
