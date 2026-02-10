import 'package:flutter/material.dart';
import '../theme/bybit_theme.dart';

class DropdownField<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;

  const DropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: BybitTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BybitTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          dropdownColor: BybitTheme.card2,
          iconEnabledColor: BybitTheme.gold,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
