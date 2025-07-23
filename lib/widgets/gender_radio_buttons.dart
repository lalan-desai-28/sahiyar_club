import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RadioOption<T> {
  final T value;
  final String label;
  final bool Function()? isVisible; // Optional visibility condition

  const RadioOption({required this.value, required this.label, this.isVisible});
}

class CustomRadioGroup<T> extends StatelessWidget {
  final String? title;
  final List<RadioOption<T>> options;
  final T? selectedValue;
  final void Function(T?) onChanged;
  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;
  final Color? activeColor;
  final TextStyle? labelStyle;
  final TextStyle? titleStyle;

  const CustomRadioGroup({
    super.key,
    this.title,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.direction = Axis.horizontal,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 8.0,
    this.activeColor,
    this.labelStyle,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Filter visible options
    final visibleOptions =
        options.where((option) {
          return option.isVisible?.call() ?? true;
        }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style:
                titleStyle ??
                Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          SizedBox(height: spacing),
        ],
        direction == Axis.horizontal
            ? Row(
              mainAxisAlignment: mainAxisAlignment,
              crossAxisAlignment: crossAxisAlignment,
              children: _buildRadioItems(context, visibleOptions),
            )
            : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildRadioItems(context, visibleOptions),
            ),
      ],
    );
  }

  List<Widget> _buildRadioItems(
    BuildContext context,
    List<RadioOption<T>> visibleOptions,
  ) {
    List<Widget> items = [];

    for (int i = 0; i < visibleOptions.length; i++) {
      final option = visibleOptions[i];

      items.add(
        InkWell(
          onTap: () => onChanged(option.value),
          borderRadius: BorderRadius.circular(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio<T>(
                value: option.value,
                groupValue: selectedValue,
                onChanged: onChanged,
                activeColor:
                    activeColor ?? Theme.of(context).colorScheme.primary,
              ),
              Text(
                option.label,
                style:
                    labelStyle ??
                    TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                    ),
              ),
            ],
          ),
        ),
      );

      // Add spacing between items (except for the last item)
      if (i < visibleOptions.length - 1) {
        if (direction == Axis.horizontal) {
          items.add(SizedBox(width: spacing));
        } else {
          items.add(SizedBox(height: spacing));
        }
      }
    }

    return items;
  }
}

// Reactive wrapper for GetX
class ReactiveRadioGroup<T> extends StatelessWidget {
  final String? title;
  final List<RadioOption<T>> options;
  final Rx<T?> selectedValue;
  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;
  final Color? activeColor;
  final TextStyle? labelStyle;
  final TextStyle? titleStyle;

  const ReactiveRadioGroup({
    super.key,
    this.title,
    required this.options,
    required this.selectedValue,
    this.direction = Axis.horizontal,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 8.0,
    this.activeColor,
    this.labelStyle,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CustomRadioGroup<T>(
        title: title,
        options: options,
        selectedValue: selectedValue.value,
        onChanged: (value) => selectedValue.value = value,
        direction: direction,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        spacing: spacing,
        activeColor: activeColor,
        labelStyle: labelStyle,
        titleStyle: titleStyle,
      ),
    );
  }
}

// Example usage for gender selection
class GenderRadioWidget extends StatelessWidget {
  final RxString selectedGender;
  final bool showGuestOption;

  const GenderRadioWidget({
    super.key,
    required this.selectedGender,
    this.showGuestOption = false,
  });

  @override
  Widget build(BuildContext context) {
    final List<RadioOption<String>> genderOptions = [
      const RadioOption(value: 'Male', label: 'Male'),
      const RadioOption(value: 'Female', label: 'Female'),
      const RadioOption(value: 'Kid', label: 'Kid'),
      RadioOption(
        value: 'Guest',
        label: 'Guest',
        isVisible: () => showGuestOption, // Conditional visibility
      ),
    ];

    return ReactiveRadioGroup<String>(
      title: 'Gender',
      options: genderOptions,
      selectedValue: selectedGender,
      direction: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }
}